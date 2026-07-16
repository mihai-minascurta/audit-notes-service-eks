output "cluster_name" {
  description = "EKS Cluster name"
  value       = aws_eks_cluster.audit_notes_cluster.name
}

output "cluster_endpoint" {
  description = "EKS API endpoint"
  value       = aws_eks_cluster.audit_notes_cluster.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Cluster CA certificate"
  value       = aws_eks_cluster.audit_notes_cluster.certificate_authority[0].data
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for IRSA"
  value = aws_eks_cluster.audit_notes_cluster.identity[0].oidc[0].issuer
}
