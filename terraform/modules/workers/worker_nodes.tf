resource "aws_eks_node_group" "workers" {
    cluster_name = var.cluster_name
    node_group_name = "audit-notes-workers"
    node_role_arn = var.worker_nodes_role_arn

    subnet_ids = var.private_subnet_ids

    scaling_config {
      desired_size = 2
      min_size = 2
      max_size = 3
    }

    instance_types = ["t3.small"]

    ami_type = "AL2023_x86_64_STANDARD"
    capacity_type = "ON_DEMAND"

     tags = {
        Name = "audit-notes-workers"
     }


  
}