# Remote State Migration

Every root in this repo started on local state (see [apply-order.md](apply-order.md) for why - each depended on reading its neighbors' state files directly off disk, which only works when applying by hand). This moves them to the shared S3 backend (`devopsgeek-tfstate-942893240157`, prefix `landing-zone/`) and wires up CI via `github-oidc/`.

## Dependency graph

```
organization/
  ├── devopsgeek-tfstate-account/
  │     └── devopsgeek-tfstate-baseline/   (also reads kubeadm-platform-account/)
  ├── devopsgeek-audit-account/
  │     └── devopsgeek-audit-baseline/
  ├── devopsgeek-log-archive-account/
  │     └── devopsgeek-log-archive-baseline/  (also reads kubeadm-platform-account/)
  └── kubeadm-platform-account/
        └── kubeadm-platform-baseline/
```

Every `*-account/` reads `organization/`'s state (OU IDs). Every `*-baseline/` reads its matching `*-account/`'s state (account ID, access role ARN). Two `*-baseline/` roots additionally cross-reference `kubeadm-platform-account/` for its account ID (used in bucket policy grants).

## Permanent exception

`devopsgeek-tfstate-account/` + `devopsgeek-tfstate-baseline/` stay on local state forever - `devopsgeek-tfstate-baseline/` creates the S3 bucket itself, so it cannot store its own state there (same reasoning as `aws-kubeadm-platform`'s `github-oidc/`). Their `terraform_remote_state` references to *other* roots still move to `backend = "s3"` once those roots migrate - only this pair's own state stays local.

## Order

Migrate top-down, fixing every downstream reference immediately after each step (a stale local reference becomes a frozen snapshot otherwise - it won't error, it'll just silently stop reflecting reality).

1. `organization/` - migrate, then update all four `*-account/` roots' `data.terraform_remote_state.organization` to `backend = "s3"`.
2. `kubeadm-platform-account/` - migrate, then update `kubeadm-platform-baseline/`'s reference.
3. `devopsgeek-audit-account/` - migrate, then update `devopsgeek-audit-baseline/`'s reference.
4. `devopsgeek-log-archive-account/` - migrate, then update `devopsgeek-log-archive-baseline/`'s reference.
5. `devopsgeek-tfstate-account/` - stays local (see above), but its own reference to `organization/` still moves to `backend = "s3"`.
6. `devopsgeek-tfstate-baseline/` - stays local (see above), but its references to `kubeadm-platform-account/` still move to `backend = "s3"` (its reference to `devopsgeek-tfstate-account/` stays local, since that one never migrates).
7. `kubeadm-platform-baseline/`, `devopsgeek-audit-baseline/`, `devopsgeek-log-archive-baseline/` - migrate. Nothing reads these via `terraform_remote_state`, so no downstream fixes needed.

## Per-root migration steps

Done manually (not via CI) - this is a sensitive, one-time, order-sensitive operation best done with direct visibility at each step.

1. Add `backend.tf`:
   ```hcl
   terraform {
     backend "s3" {
       bucket       = "devopsgeek-tfstate-942893240157"
       key          = "landing-zone/<root-name>/terraform.tfstate"
       region       = "eu-central-1"
       encrypt      = true
       use_lockfile = true
     }
   }
   ```
2. `terraform init` - Terraform detects the backend change and asks to copy existing state to the new backend. Answer yes.
3. `terraform plan` - must show **no changes**. This confirms the migration moved metadata only, nothing was touched on AWS's side.
4. Fix any other root's `data "terraform_remote_state"` block that pointed at this root's old local path (see Order above).

## After migration

Once a root is confirmed on S3, its future changes go through CI (`terraform.yml` reusable workflow, same pattern as `aws-kubeadm-platform`) instead of manual `terraform apply`. `apply-order.md` needs a follow-up update once this is complete - it currently says every root has "its own local state," which stops being true.
