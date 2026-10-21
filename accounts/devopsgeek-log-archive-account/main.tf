data "terraform_remote_state" "organization" {
  backend = "local"

  config = {
    path = "../../organization/terraform.tfstate"
  }
}

module "this" {
  source = "../../modules/aws-account"

  account_name  = "devopsgeek-log-archive"
  account_email = "darko.bjelicic99+devopsgeeklogarchive@gmail.com"
  parent_id     = data.terraform_remote_state.organization.outputs.security_ou_id
  tags          = { Purpose = "Centralized log archive - reserved - not yet active" }
}
