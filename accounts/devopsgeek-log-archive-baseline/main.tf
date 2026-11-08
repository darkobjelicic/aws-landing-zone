data "terraform_remote_state" "account" {
  backend = "s3"

  config = {
    bucket = "devopsgeek-tfstate-942893240157"
    key    = "landing-zone/devopsgeek-log-archive-account/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "baseline" {
  source = "../../modules/account-baseline"

  providers = {
    aws        = aws
    aws.target = aws.target
  }
}
