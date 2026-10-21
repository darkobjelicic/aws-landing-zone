output "account_id" {
  description = "AWS account ID"
  value       = module.this.account_id
}

output "access_role_arn" {
  description = "ARN of the auto-created cross-account access role"
  value       = module.this.access_role_arn
}