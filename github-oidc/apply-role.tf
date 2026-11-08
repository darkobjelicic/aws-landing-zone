resource "aws_iam_role" "github_actions_apply" {
  name = "github-actions-apply"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = "repo:darkobjelicic@116880434/aws-landing-zone@1420885062:environment:production"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_apply_org" {
  name = "github-actions-apply-org"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "OrganizationsScoped"
        Effect   = "Allow"
        Action   = concat(local.organizations_read_actions, local.organizations_write_actions)
        Resource = "*"
      },
      {
        Sid      = "SsoIdentityStoreScoped"
        Effect   = "Allow"
        Action   = concat(local.sso_identitystore_read_actions, local.sso_identitystore_write_actions)
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_apply_assume" {
  name = "github-actions-apply-assume"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AssumeIntoMemberAccounts"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::*:role/OrganizationAccountAccessRole"
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_apply_s3" {
  name = "github-actions-apply-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "StateBucketObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "arn:aws:s3:::devopsgeek-tfstate-942893240157/landing-zone/*"
      },
      {
        Sid      = "StateBucketListOwnPrefix"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::devopsgeek-tfstate-942893240157"
        Condition = {
          StringLike = {
            "s3:prefix" = ["landing-zone/*"]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_apply_org" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = aws_iam_policy.github_actions_apply_org.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_apply_assume" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = aws_iam_policy.github_actions_apply_assume.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_apply_s3" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = aws_iam_policy.github_actions_apply_s3.arn
}