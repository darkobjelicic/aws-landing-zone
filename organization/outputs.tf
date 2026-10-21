output "security_ou_id" {
  description = "ID of the Security OU"
  value       = aws_organizations_organizational_unit.security.id
}

output "infrastructure_ou_id" {
  description = "ID of the Infrastructure OU"
  value       = aws_organizations_organizational_unit.infrastructure.id
}

output "sandbox_ou_id" {
  description = "ID of the Sandbox OU"
  value       = aws_organizations_organizational_unit.sandbox.id
}

output "workloads_ou_id" {
  description = "ID of the Workloads OU"
  value       = aws_organizations_organizational_unit.workloads.id
}