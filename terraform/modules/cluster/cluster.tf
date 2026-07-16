#EKS Cluster
resource "aws_eks_cluster" "audit_notes_cluster" {
    name = var.cluster_name
    version = var.kubernetes_version
    role_arn = var.cluster_role_arn

    vpc_config {
      subnet_ids = var.subnet_ids
    }

    tags = {
        Name = "audit-notes-eks"
    }
  
}