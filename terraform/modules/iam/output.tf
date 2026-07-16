output "cluster_role_arn" {
  description = "IAM Role ARN for the EKS Control Plane"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "worker_nodes_role_arn" {
  description = "IAM Role ARN for the Worker Nodes"
  value       = aws_iam_role.worker_nodes_role.arn
}

