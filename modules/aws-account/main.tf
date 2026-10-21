resource "aws_organizations_account" "this" {
  name      = var.account_name
  email     = var.account_email
  parent_id = var.parent_id
  tags      = merge({ ManagedBy = "Terraform" }, var.tags)

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_ssoadmin_instances" "this" {}

data "aws_identitystore_group" "admin" {
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = var.admin_group_name
    }
  }
}

data "aws_ssoadmin_permission_set" "admin" {
  instance_arn = data.aws_ssoadmin_instances.this.arns[0]
  name         = var.permission_set_name
}

resource "aws_ssoadmin_account_assignment" "admin" {
  instance_arn       = data.aws_ssoadmin_instances.this.arns[0]
  permission_set_arn = data.aws_ssoadmin_permission_set.admin.arn

  principal_id   = data.aws_identitystore_group.admin.group_id
  principal_type = "GROUP"

  target_id   = aws_organizations_account.this.id
  target_type = "AWS_ACCOUNT"
}
