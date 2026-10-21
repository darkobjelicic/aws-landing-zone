provider "aws" {
  region  = "eu-central-1"
  profile = "devopsgeek-admin"
}

provider "aws" {
  alias   = "target"
  region  = "eu-central-1"
  profile = "devopsgeek-admin"

  assume_role {
    role_arn = data.terraform_remote_state.account.outputs.access_role_arn
  }
}
