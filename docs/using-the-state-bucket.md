# Using the shared state bucket

`devopsgeek-tfstate` (created by `accounts/devopsgeek-tfstate-baseline/`) is the **organization-wide** Terraform state bucket — not specific to any one project. Every Terraform root, in any project, gets its own key (object) inside this one bucket. No project creates its own bucket.

## Key naming convention

- Single-root project: `<project-name>/terraform.tfstate`
- Multi-root project: `<project-name>/<component>/terraform.tfstate`, where `<component>` is the actual name of that Terraform root directory (not a generic placeholder)

Example — `aws-kubeadm-platform` has separate Terraform roots (`networking/`, `compute/`, `iam/`, `github-oidc/`), so it uses one key per root:

kubeadm-platform/networking/terraform.tfstate
kubeadm-platform/compute/terraform.tfstate
kubeadm-platform/iam/terraform.tfstate
kubeadm-platform/github-oidc/terraform.tfstate

## Granting a new project access

The bucket has a policy (`accounts/devopsgeek-tfstate-baseline/main.tf`, `aws_s3_bucket_policy.tfstate`) that allow-lists one AWS account per project, scoped to that project's own key prefix. There is no org-wide grant — a new consuming account gets nothing until its own statement pair is added.

Before a new project's Terraform can use this bucket:

1. In `accounts/devopsgeek-tfstate-baseline/main.tf`, add a `terraform_remote_state` data source pointing at the new project's `*-account/terraform.tfstate` (to read its `account_id`).
2. Add one statement pair to `aws_s3_bucket_policy.tfstate`'s `Statement` list — one for `s3:GetObject`/`PutObject`/`DeleteObject` on `<bucket-arn>/<project-name>/*`, one for `s3:ListBucket` on the bucket itself with a `s3:prefix` condition matching `<project-name>/*`. Both scoped to the new account's root ARN (`arn:aws:iam::<account_id>:root`).
3. Apply `devopsgeek-tfstate-baseline/`.

A single bucket policy document has a hard 20 KB limit (not adjustable) - each project's statement pair is roughly 500 bytes, so this comfortably covers dozens of projects.

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