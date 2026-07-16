#IAM Role for GitHub Actions 
resource "aws_iam_role" "github_actions" {

  name = "github-actions-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {

          Federated = aws_iam_openid_connect_provider.github.arn

        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:mihai-minascurta@*/audit-notes-service-eks@*:ref:refs/heads/*"
          }
        }

      }

    ]

  })

}

#Policy for GitHub IAM Role (given administrator permission because we need full access at workflow,for now)
resource "aws_iam_role_policy_attachment" "administrator" {

  role = aws_iam_role.github_actions.name

  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

}
