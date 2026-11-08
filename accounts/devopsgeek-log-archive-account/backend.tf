terraform {
  backend "s3" {
    bucket       = "devopsgeek-tfstate-942893240157"
    key          = "landing-zone/devopsgeek-log-archive-account/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
