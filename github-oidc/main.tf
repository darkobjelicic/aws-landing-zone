data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

locals {
  organizations_read_actions = [
    "organizations:DescribeOrganization",
    "organizations:DescribeOrganizationalUnit",
    "organizations:DescribeAccount",
    "organizations:DescribePolicy",
    "organizations:DescribeCreateAccountStatus",
    "organizations:ListRoots",
    "organizations:ListOrganizationalUnitsForParent",
    "organizations:ListAccounts",
    "organizations:ListAccountsForParent",
    "organizations:ListPolicies",
    "organizations:ListPoliciesForTarget",
    "organizations:ListTargetsForPolicy",
    "organizations:ListTagsForResource",
  ]

  organizations_write_actions = [
    "organizations:CreateAccount",
    "organizations:CreateOrganizationalUnit",
    "organizations:CreatePolicy",
    "organizations:UpdatePolicy",
    "organizations:DeletePolicy",
    "organizations:DeleteOrganizationalUnit",
    "organizations:AttachPolicy",
    "organizations:DetachPolicy",
    "organizations:TagResource",
    "organizations:UntagResource",
    "organizations:MoveAccount",
  ]

  sso_identitystore_read_actions = [
    "sso-admin:ListInstances",
    "sso-admin:DescribePermissionSet",
    "sso-admin:ListAccountAssignments",
    "sso-admin:DescribeAccountAssignmentCreationStatus",
    "identitystore:DescribeGroup",
    "identitystore:GetGroupId",
    "identitystore:ListGroups",
  ]

  sso_identitystore_write_actions = [
    "sso-admin:CreateAccountAssignment",
    "sso-admin:DeleteAccountAssignment",
  ]
}
