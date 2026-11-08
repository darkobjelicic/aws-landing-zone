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

  account_name  = "devopsgeek-log-archive"
  account_email = "darko.bjelicic99+devopsgeeklogarchive@gmail.com"
  parent_id     = data.terraform_remote_state.organization.outputs.security_ou_id
  tags = { Purpose = "Centralized log archive for aws-kubeadm-platform VPC Flow Logs" }
}
