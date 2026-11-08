resource "aws_iam_role" "github_actions_plan" {
  name = "github-actions-plan"

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
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:darkobjelicic@116880434/aws-landing-zone@1420885062:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_plan_org" {
  name = "github-actions-plan-org"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "OrganizationsReadOnly"
        Effect   = "Allow"
        Action   = local.organizations_read_actions
        Resource = "*"
      },
      {
        Sid      = "SsoIdentityStoreReadOnly"
        Effect   = "Allow"
        Action   = local.sso_identitystore_read_actions
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "github_actions_plan_assume" {
  name = "github-actions-plan-assume"

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

resource "aws_iam_policy" "github_actions_plan_s3" {
  name = "github-actions-plan-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "StateReadOnly"
        Effect   = "Allow"
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::devopsgeek-tfstate-942893240157/landing-zone/*"
      },
      {
        Sid    = "LockFileOnly"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "arn:aws:s3:::devopsgeek-tfstate-942893240157/landing-zone/*.tflock"
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

resource "aws_iam_role_policy_attachment" "github_actions_plan_org" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = aws_iam_policy.github_actions_plan_org.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_plan_assume" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = aws_iam_policy.github_actions_plan_assume.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_plan_s3" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = aws_iam_policy.github_actions_plan_s3.arn
}
