output "tfstate_bucket_name" {
  description = "Name of the S3 bucket other Terraform configs should use as their remote state backend"
  value       = aws_s3_bucket.tfstate.id
}
