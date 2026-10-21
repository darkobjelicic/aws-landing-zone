# Using the shared state bucket

`devopsgeek-tfstate` (created by `accounts/devopsgeek-tfstate-baseline/`) is the **organization-wide** Terraform state bucket — not specific to any one project. Every Terraform root, in any project, gets its own key (object) inside this one bucket. No project creates its own bucket.

## Key naming convention

- Single-root project: `<project-name>/terraform.tfstate`
- Multi-root project: `<project-name>/<component>/terraform.tfstate`, where `<component>` is the actual name of that Terraform root directory (not a generic placeholder)

Example — `aws-kubeadm-platform` has three separate Terraform roots (`networking/`, `compute/`, `iam/`), so it uses three keys:

kubeadm-platform/networking/terraform.tfstate
kubeadm-platform/compute/terraform.tfstate
kubeadm-platform/iam/terraform.tfstate

## Backend block for consumers

```hcl
terraform {
  backend "s3" {
    bucket       = "devopsgeek-tfstate-<account_id>"
    key          = "kubeadm-platform/compute/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

Get the exact bucket name (it has the account ID suffix) from the tfstate_bucket_name output in accounts/devopsgeek-tfstate-baseline/.