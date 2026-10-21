resource "aws_s3_account_public_access_block" "this" {
  provider = aws.target

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_ebs_encryption_by_default" "this" {
  provider = aws.target
  enabled  = true
}
