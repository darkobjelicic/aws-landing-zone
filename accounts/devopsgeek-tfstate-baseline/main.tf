data "terraform_remote_state" "account" {
  backend = "local"

  config = {
    path = "../devopsgeek-tfstate-account/terraform.tfstate"
  }
}

data "terraform_remote_state" "kubeadm_platform_account" {
  backend = "local"

  config = {
    path = "../kubeadm-platform-account/terraform.tfstate"
  }
}

module "baseline" {
  source = "../../modules/account-baseline"

  providers = {
    aws        = aws
    aws.target = aws.target
  }
}
