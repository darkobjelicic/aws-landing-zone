# Local Setup

Tooling required on a workstation to run this repo's Terraform.

## AWS CLI

1. Install AWS CLI v2 using the [official installer](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) (not apt/snap - see rationale below).

2. Configure an SSO profile:

   ```bash
   aws configure sso
   ```

   Use profile name `devopsgeek-admin` - every `providers.tf` in this repo references it by name.

3. Before each session, refresh the SSO token:

   ```bash
   aws sso login --profile devopsgeek-admin
   ```

## Terraform via tfenv

1. Install `tfenv` (not apt/snap - see rationale below):

   ```bash
   git clone https://github.com/tfutils/tfenv.git ~/.tfenv
   echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

2. Install and activate the version pinned in `.terraform-version` at the repo root (currently `1.16.6`):

   ```bash
   tfenv install 1.16.6
   tfenv use 1.16.6
   ```

   `tfenv install` and `tfenv use` with no argument also work - both fall back to reading `.terraform-version` automatically.

## Why not apt/snap

Both lag behind official releases, and snap's confinement can restrict file access Terraform needs. `tfenv` and the official AWS CLI installer track upstream releases directly and let this repo pin an exact version (`.terraform-version`, `required_version` in each `versions.tf`).
