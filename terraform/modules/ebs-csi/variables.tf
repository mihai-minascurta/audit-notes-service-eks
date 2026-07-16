variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "oidc_issuer_url" {
  description = "EKS OIDC issuer URL"
  type        = string
}