data "terraform_remote_state" "organization" {
  backend = "local"

  config = {
    path = "../../organization/terraform.tfstate"
  }
}

module "this" {
  source = "../../modules/aws-account"

  account_name  = "devopsgeek-tfstate"
  account_email = "darko.bjelicic99+devopsgeektfstate@gmail.com"
  parent_id     = data.terraform_remote_state.organization.outputs.infrastructure_ou_id
  tags          = { Purpose = "Terraform remote state storage" }
}

