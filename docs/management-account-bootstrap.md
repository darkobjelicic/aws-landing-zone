# Management Account Bootstrap

One-time, manual actions performed directly on the `devopsgeek` management account. None of this is managed by Terraform in this repo — the management account itself predates this repo and is out of scope (see root README).

## Steps

1. **Enable IAM Identity Center** (console, Identity Center service, chosen home region).

2. **Create an admin group and user**:
   - Group: `Admin`
   - User: `darko.bjelicic`
   - Assign the `AdministratorAccess` permission set to the group, at the management account level.

3. **Create a budget alert** (console, Billing and Cost Management → Budgets):
   - Monthly cost budget.
   - Alert action triggered at a chosen threshold.

4. **Enable the `SERVICE_CONTROL_POLICY` policy type on the organization root**:

   ```bash
   aws organizations list-roots --profile devopsgeek-admin
   # note the root ID, e.g. r-5npf

   aws organizations enable-policy-type \
     --root-id <root-id> \
     --policy-type SERVICE_CONTROL_POLICY \
     --profile devopsgeek-admin
   ```

   Status goes to `PENDING_ENABLE` first - check with the `list-roots` command above until it shows `ENABLED` before running `terraform apply` in `organization/`.

   Required before any SCP can be attached - see [apply-order.md](apply-order.md).

5. **Enable AWS service access for IAM Access Analyzer**, before registering any delegated administrator:

   ```bash
   aws organizations enable-aws-service-access \
     --service-principal access-analyzer.amazonaws.com \
     --profile devopsgeek-admin

   aws organizations list-aws-service-access-for-organization --profile devopsgeek-admin
   # confirm access-analyzer.amazonaws.com is listed
   ```

   Required before `accounts/devopsgeek-audit-account/` can register the delegated administrator - see [apply-order.md](apply-order.md).

6. **Create the Access Analyzer service-linked role in the management account**, before creating an `ORGANIZATION`-type analyzer:

   ```bash
   aws iam get-role --role-name AWSServiceRoleForAccessAnalyzer --profile devopsgeek-admin
   # if NoSuchEntity:

   aws iam create-service-linked-role \
     --aws-service-name access-analyzer.amazonaws.com \
     --profile devopsgeek-admin
   ```

   An `ORGANIZATION`-type analyzer has to enumerate resources across the whole org, which requires this role in the **management account** specifically - not in `devopsgeek-audit` where the analyzer itself is created. Without it, `aws_accessanalyzer_analyzer.organization` in `accounts/devopsgeek-audit-baseline/` fails with `ConflictException: Access Analyzer Service Linked Role is not in the organizational management account`.

## Why these aren't in Terraform

These are foundational, one-time toggles on an account that already existed before this repo - not resources with an ongoing lifecycle this Terraform should own.

## Enabling other services for delegated administration (reference)

Not used in this repo yet - kept here for when it is. Always two separate steps, in order:

**Step A - enable trusted access** (CLI, same command for every service, only the principal changes):

```bash
aws organizations enable-aws-service-access --service-principal <principal> --profile devopsgeek-admin
```

**Step B - register the delegated administrator account.** This is where services differ - some have a generic Terraform resource, GuardDuty has its own:

| Service | Principal for step A | How step B is done |
|---|---|---|
| IAM Access Analyzer | `access-analyzer.amazonaws.com` | `aws_organizations_delegated_administrator` (Terraform, generic resource - same one used in `accounts/devopsgeek-audit-account/`) |
| AWS Config (aggregator) | `config.amazonaws.com` | `aws_organizations_delegated_administrator` (Terraform, generic resource) |
| AWS Config (org rules / conformance packs) | `config-multiaccountsetup.amazonaws.com` | `aws_organizations_delegated_administrator` (Terraform, generic resource) - separate principal from the aggregator row above, same mechanism |
| GuardDuty | `guardduty.amazonaws.com` | `aws_guardduty_organization_admin_account` (Terraform, but a GuardDuty-specific resource - does *not* use `aws_organizations_delegated_administrator`) |
