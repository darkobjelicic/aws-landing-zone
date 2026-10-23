data "terraform_remote_state" "account" {
  backend = "local"

  config = {
    path = "../devopsgeek-tfstate-account/terraform.tfstate"
  }
}

data "terraform_remote_state" "kubeadm_platform_account" {
  backend = "local"

  config = {
    path = "../kubeadm-platform-account/terraform.tfstate"
  }
}

module "baseline" {
  source = "../../modules/account-baseline"

  providers = {
    aws        = aws
    aws.target = aws.target
  }
}

resource "aws_s3_bucket" "tfstate" {
  provider = aws.target
  bucket   = "devopsgeek-tfstate-${data.terraform_remote_state.account.outputs.account_id}"

  tags = {
    Name      = "Terraform State"
    ManagedBy = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  provider = aws.target
  bucket   = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  provider = aws.target
  bucket   = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  provider = aws.target
  bucket   = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  provider = aws.target
  bucket   = aws_s3_bucket.tfstate.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

resource "aws_s3_bucket_policy" "tfstate" {
  provider = aws.target
  bucket   = aws_s3_bucket.tfstate.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "KubeadmPlatformObjectAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.terraform_remote_state.kubeadm_platform_account.outputs.account_id}:root"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "${aws_s3_bucket.tfstate.arn}/kubeadm-platform/*"
      },
      {
        Sid    = "KubeadmPlatformListOwnPrefix"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.terraform_remote_state.kubeadm_platform_account.outputs.account_id}:root"
        }
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.tfstate.arn
        Condition = {
          StringLike = {
            "s3:prefix" = ["kubeadm-platform/*"]
          }
        }
      }
    ]
  })
}