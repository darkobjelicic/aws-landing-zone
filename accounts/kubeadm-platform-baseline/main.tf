data "terraform_remote_state" "account" {
  backend = "s3"

  config = {
    bucket = "devopsgeek-tfstate-942893240157"
    key    = "landing-zone/kubeadm-platform-account/terraform.tfstate"
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
