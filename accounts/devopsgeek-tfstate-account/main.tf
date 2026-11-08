data "terraform_remote_state" "organization" {
  backend = "s3"

  config = {
    bucket = "devopsgeek-tfstate-942893240157"
    key    = "landing-zone/organization/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "this" {
  source = "../../modules/aws-account"

  account_name  = "devopsgeek-tfstate"
  account_email = "darko.bjelicic99+devopsgeektfstate@gmail.com"
  parent_id     = data.terraform_remote_state.organization.outputs.infrastructure_ou_id
  tags          = { Purpose = "Terraform remote state storage" }
}

