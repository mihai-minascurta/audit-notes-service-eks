output "alb_controller_role_arn" {

  description = "IAM Role ARN used by AWS Load Balancer Controller"

  value = aws_iam_role.alb_controller_role.arn

}

