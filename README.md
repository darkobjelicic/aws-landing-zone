# aws-landing-zone

Terraform-managed AWS Organization structure: accounts, organizational units, and baseline security settings. Implemented directly rather than via AWS Control Tower, which adds ongoing cost (AWS Config across all accounts) not justified at this account count. See `docs/` for operational runbooks.

## Organizational units

- `Security` - security tooling accounts (`devopsgeek-log-archive`, `devopsgeek-audit`)
- `Infrastructure` - shared, non-project-specific accounts (`devopsgeek-tfstate`)
- `Workloads` - project accounts (`kubeadm-platform`)
- `Sandbox` - reserved, empty, no accounts yet

All four OUs have a `deny_leave_org` SCP attached.

## Accounts

| Account | OU | Purpose |
|---|---|---|
| `devopsgeek` | (management, root) | Organization root. Already existed, not managed by this Terraform. |
| `devopsgeek-tfstate` | Infrastructure | Terraform remote state storage |
| `kubeadm-platform` | Workloads | Workload account for [aws-kubeadm-platform](https://github.com/darkobjelicic/aws-kubeadm-platform) |
| `devopsgeek-log-archive` | Security | Centralized log archive (reserved, not yet active - no CloudTrail trail configured) |
| `devopsgeek-audit` | Security | Security tooling; Access Analyzer delegated administrator for the whole organization |

Every account gets, via `modules/account-baseline`: S3 account-level public access block, EBS encryption by default. `devopsgeek-audit` additionally hosts the single ORGANIZATION-type IAM Access Analyzer covering all accounts.

## Structure

- `organization/` - OUs and SCPs. Applied first; nothing else exists until this does.
- `modules/aws-account/` - reusable: creates one account + Identity Center admin access.
- `modules/account-baseline/` - reusable: applies baseline settings inside one account (needs an `aws.target` provider assumed into that account).
- `accounts/<name>-account/` - one per account, calls `modules/aws-account`.
- `accounts/<name>-baseline/` - one per account, calls `modules/account-baseline`. Separate from `*-account` because Terraform can't configure a provider that depends on a resource created in the same apply - see [docs/apply-order.md](docs/apply-order.md).

## Docs

- [docs/management-account-bootstrap.md](docs/management-account-bootstrap.md) - one-time manual setup on the management account, do this first
- [docs/local-setup.md](docs/local-setup.md) - tooling required on your workstation
- [docs/apply-order.md](docs/apply-order.md) - Terraform apply sequence, read before running anything
- [docs/using-the-state-bucket.md](docs/using-the-state-bucket.md) - shared state bucket conventions, for this and future projects
- [docs/state-recovery.md](docs/state-recovery.md) - recovering from a lost state file
