data "aws_organizations_organization" "this" {}

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = data.aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "infrastructure" {
  name      = "Infrastructure"
  parent_id = data.aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = data.aws_organizations_organization.this.roots[0].id
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = data.aws_organizations_organization.this.roots[0].id
}

data "aws_iam_policy_document" "deny_leave_org" {
  statement {
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization"]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "deny_leave_org" {
  name    = "deny-leave-organization"
  type    = "SERVICE_CONTROL_POLICY"
  content = data.aws_iam_policy_document.deny_leave_org.json
}

resource "aws_organizations_policy_attachment" "deny_leave_org_security" {
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = aws_organizations_organizational_unit.security.id
}

resource "aws_organizations_policy_attachment" "deny_leave_org_infrastructure" {
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = aws_organizations_organizational_unit.infrastructure.id
}

resource "aws_organizations_policy_attachment" "deny_leave_org_sandbox" {
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = aws_organizations_organizational_unit.sandbox.id
}

resource "aws_organizations_policy_attachment" "deny_leave_org_workloads" {
  policy_id = aws_organizations_policy.deny_leave_org.id
  target_id = aws_organizations_organizational_unit.workloads.id
}
