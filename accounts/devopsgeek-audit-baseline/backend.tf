terraform {
  backend "s3" {
    bucket       = "devopsgeek-tfstate-942893240157"
    key          = "landing-zone/devopsgeek-audit-baseline/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}