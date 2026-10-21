output "account_id" {
  description = "AWS account ID"
  value       = aws_organizations_account.this.id
}

output "access_role_arn" {
  description = "ARN of the auto-created role for cross-account access from the management account"
  value       = "arn:aws:iam::${aws_organizations_account.this.id}:role/OrganizationAccountAccessRole"
}
