data "tls_certificate" "eks_oidc" {
  url = var.oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {

  url = var.oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint
  ]
}

resource "aws_iam_role" "ebs_csi_role" {

  name = "${var.cluster_name}-ebs-csi-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${replace(var.oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
            "${replace(var.oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {

  role = aws_iam_role.ebs_csi_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"

}