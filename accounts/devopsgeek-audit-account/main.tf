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

  account_name  = "devopsgeek-audit"
  account_email = "darko.bjelicic99+devopsgeekaudit@gmail.com"
  parent_id     = data.terraform_remote_state.organization.outputs.security_ou_id
  tags          = { Purpose = "Security tooling - Access Analyzer delegated administrator" }
}

resource "aws_organizations_delegated_administrator" "access_analyzer" {
  account_id        = module.this.account_id
  service_principal = "access-analyzer.amazonaws.com"
}
