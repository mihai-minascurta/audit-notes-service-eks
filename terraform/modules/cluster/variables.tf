variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "cluster_role_arn" {
  description = "IAM Role ARN used by the EKS Control Plane"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets where the EKS control plane connects"
  type        = list(string)
}

