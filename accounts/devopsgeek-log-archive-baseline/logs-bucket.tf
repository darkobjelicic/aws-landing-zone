data "terraform_remote_state" "kubeadm_platform_account" {
  backend = "s3"

  config = {
    bucket = "devopsgeek-tfstate-942893240157"
    key    = "landing-zone/kubeadm-platform-account/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_s3_bucket" "logs" {
  provider = aws.target
  bucket   = "devopsgeek-log-archive-${data.terraform_remote_state.account.outputs.account_id}"

  tags = {
    Name = "Log Archive"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "logs" {
  provider = aws.target
  bucket   = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  provider = aws.target
  bucket   = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  provider = aws.target
  bucket   = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  provider = aws.target
  bucket   = aws_s3_bucket.logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 90
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  provider = aws.target
  bucket   = aws_s3_bucket.logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "KubeadmPlatformFlowLogsWrite"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.logs.arn}/kubeadm-platform/vpc-flow-logs/AWSLogs/${data.terraform_remote_state.kubeadm_platform_account.outputs.account_id}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.terraform_remote_state.kubeadm_platform_account.outputs.account_id
            "s3:x-amz-acl"      = "bucket-owner-full-control"
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:eu-central-1:${data.terraform_remote_state.kubeadm_platform_account.outputs.account_id}:*"
          }
        }
      },
      {
        Sid    = "KubeadmPlatformFlowLogsAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.logs.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.terraform_remote_state.kubeadm_platform_account.outputs.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:logs:eu-central-1:${data.terraform_remote_state.kubeadm_platform_account.outputs.account_id}:*"
          }
        }
      }
    ]
  })
}
