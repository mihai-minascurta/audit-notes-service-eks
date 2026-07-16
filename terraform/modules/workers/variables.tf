variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "worker_nodes_role_arn" {
  description = "IAM Role ARN for Worker Nodes"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the Worker Nodes"
  type        = list(string)
}