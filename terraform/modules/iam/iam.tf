
#IAM Role for EKS Cluster Control Plane
resource "aws_iam_role" "eks_cluster_role" {
  name = "audit-notes-eks-cluster-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
        {
            Effect = "Allow"

            Principal = {
                Service = "eks.amazonaws.com"
            }

            Action = "sts:AssumeRole"
        }
    ]
  })
}

#Attachment the policy to the IAM ROle for EKS Cluster Control PLane
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {

  role = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

#IAM Role for our Worker Nodes (EC2) 
resource "aws_iam_role" "worker_nodes_role" {
    name = "audit-notes-worker-nodes-role"

      assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
        {
            Effect = "Allow"

            Principal = {
                Service = "ec2.amazonaws.com"
            }

            Action = "sts:AssumeRole"
        }
    ]
  })
  
}

#EC2 to register to our cluster
resource "aws_iam_role_policy_attachment" "worker_nodes_register_to_cluster" {

  role = aws_iam_role.worker_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}

#EC2 to docker pull from ECR
resource "aws_iam_role_policy_attachment" "worker_nodes_pull_from_ECR" {

  role = aws_iam_role.worker_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

#EC2 to manage IP and ENI for pods (IDK yet what is ENI)
resource "aws_iam_role_policy_attachment" "worker_nodes_manage_ip_eni" {

  role = aws_iam_role.worker_nodes_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

}
