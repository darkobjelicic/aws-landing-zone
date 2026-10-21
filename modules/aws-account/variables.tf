variable "account_name" {
  description = "Name of the AWS account, shown in Organizations and Billing"
  type        = string
}

variable "account_email" {
  description = "Root email for the new account. Must be globally unique across all of AWS"
  type        = string
}

variable "tags" {
  description = "Tags applied to the account"
  type        = map(string)
  default     = {}
}

variable "admin_group_name" {
  description = "Identity Center group granted access to this account"
  type        = string
  default     = "Admin"
}

variable "permission_set_name" {
  description = "Identity Center permission set granted to admin_group_name on this account"
  type        = string
  default     = "AdministratorAccess"
}

variable "parent_id" {
  description = "ID of the OU (or Organization root) this account should be placed under"
  type        = string
}