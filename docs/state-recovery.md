# State Recovery

All state in this repo is local (gitignored) by design - see root README.

## If a state file is lost

1. Do **not** run `terraform apply` blindly - it will try to recreate resources that already exist in AWS.
2. Run `terraform plan` first in the affected directory. Review every proposed change.
3. Import each resource `plan` wants to create, instead of letting it recreate:

   ```bash
   terraform import <resource_address> <real_world_id>
   ```

   Worked example - recovering `accounts/devopsgeek-tfstate-account/` state:

   ```bash
   cd accounts/devopsgeek-tfstate-account
   terraform plan
   # plan shows module.this.aws_organizations_account.this would be created

   # Find the real account ID in the AWS Organizations console,
   # then import it instead of letting plan create a duplicate:
   terraform import module.this.aws_organizations_account.this 123456789012

   terraform plan
   # should now show no changes for that resource
   ```

   The import ID format is different for every resource type (sometimes just an ID like above, sometimes a composite string). Check the **Import** section of that resource's page on the [Terraform AWS provider docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) - don't guess the format.

4. Re-run `terraform plan` - expect no changes.

## Where to find addresses and IDs

| Root directory | Creates | Find real-world ID via |
|---|---|---|
| `organization/` | OUs, SCP | AWS Organizations console |
| `accounts/*-account/` | 1 AWS account, SSO assignment | AWS Organizations console (account ID) |
| `accounts/devopsgeek-audit-account/` | + delegated administrator | IAM → Delegated administrators |
| `accounts/*-baseline/` | S3 block, EBS encryption | AWS Console, inside that account |
| `accounts/devopsgeek-audit-baseline/` | + ORGANIZATION Access Analyzer | IAM Access Analyzer, inside the audit account |

Resource **addresses** (the `<resource_address>` part) are visible by reading the `.tf` files in that directory - resources inside a module call are prefixed, e.g. `module.this.aws_organizations_account.this`.

## Why there's no backup strategy

Footprint per root ranges from 2 resources (most `*-baseline/` directories) to 9 (`organization/`). Import-based recovery is sufficient at this scale. Reference: [burakdede.com - the Terraform bootstrap problem](https://burakdede.com/blog/the-terraform-bootstrap-problem-how-to-create-your-state-backend-without-going-insane/).
