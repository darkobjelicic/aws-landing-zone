data "terraform_remote_state" "account" {
  backend = "local"

  config = {
    path = "../devopsgeek-audit-account/terraform.tfstate"
  }
}

module "baseline" {
  source = "../../modules/account-baseline"

  providers = {
    aws        = aws
    aws.target = aws.target
  }
}

resource "aws_accessanalyzer_analyzer" "organization" {
  provider      = aws.target
  analyzer_name = "devopsgeek-organization-access-analyzer"
  type          = "ORGANIZATION"
}
