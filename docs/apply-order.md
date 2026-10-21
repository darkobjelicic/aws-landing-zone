# Apply Order

Each directory under `organization/` and `accounts/*` is an independent Terraform root with its own local state. Nothing enforces apply order automatically across them - follow this sequence.

## Order

1. `organization/` - creates OUs and the deny-leave-org SCP
2. `accounts/*-account/` - all of them, any order among themselves
3. `accounts/*-baseline/` - all of them, any order among themselves

## Why

- `*-account/` reads `organization/`'s state (OU IDs) via `terraform_remote_state` - `organization/` must be applied first.
- `*-baseline/` reads its matching `*-account/`'s state (account ID, access role ARN) via `terraform_remote_state` - that account must be applied first. Doing all accounts before any baseline (rather than interleaving per account) keeps this simple and is always safe.

## The audit account specifically

`devopsgeek-audit-account/` runs from the **management account** and does two things: creates the `devopsgeek-audit` account, and registers it as the **delegated administrator** for IAM Access Analyzer (`aws_organizations_delegated_administrator`). This is a permission grant - "this account may now manage Access Analyzer for the whole organization" - it does not create the analyzer itself.

`devopsgeek-audit-baseline/` runs from **inside** the `devopsgeek-audit` account (via the `aws.target` assumed-role provider) and creates the actual `ORGANIZATION`-type analyzer. If this ran before the delegation step above completed, AWS would reject the `CreateAnalyzer` call outright - the account wouldn't yet be registered as delegated administrator. This is already covered by the general rule above (all `*-account/` before all `*-baseline/`), not a separate ordering rule - it's just the reason that rule matters more here than for the other accounts.
