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

  account_name  = "kubeadm-platform"
  account_email = "darko.bjelicic99+kubeadmplatform@gmail.com"
  parent_id     = data.terraform_remote_state.organization.outputs.workloads_ou_id
  tags          = { Purpose = "kubeadm CKA lab workload" }
}
