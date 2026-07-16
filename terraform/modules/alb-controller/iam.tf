data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "alb_controller_policy" {

  name = "${var.cluster_name}-alb-controller-policy"

  policy = file("${path.module}/alb_controller_policy.json")

}

resource "aws_iam_role" "alb_controller_role" {

  name = "${var.cluster_name}-alb-controller-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.oidc_issuer_url, "https://", "")}"
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {

          StringEquals = {

            "${replace(var.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"

            "${replace(var.oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"

          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy_attachment" {

  role       = aws_iam_role.alb_controller_role.name

  policy_arn = aws_iam_policy.alb_controller_policy.arn

}