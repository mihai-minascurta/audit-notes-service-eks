module "networking" {
  source = "../../modules/networking"
}

module "iam" {
  source = "../../modules/iam"
}

module "cluster" {
  source = "../../modules/cluster"

  cluster_name       = "audit-notes-eks"
  kubernetes_version = "1.35"

  cluster_role_arn = module.iam.cluster_role_arn

  subnet_ids = [
    module.networking.public_subnet_a_id,
    module.networking.public_subnet_b_id,
    module.networking.private_subnet_a_id,
    module.networking.private_subnet_b_id
  ]
}

module "workers" {
  source = "../../modules/workers"

  cluster_name = module.cluster.cluster_name

  worker_nodes_role_arn = module.iam.worker_nodes_role_arn

  private_subnet_ids = [
    module.networking.private_subnet_a_id,
    module.networking.private_subnet_b_id
  ]
}

module "ebs_csi" {

  source = "../../modules/ebs-csi"

  cluster_name = module.cluster.cluster_name

  oidc_issuer_url = module.cluster.oidc_issuer_url
}

module "alb_controller" {

  source = "../../modules/alb-controller"

  cluster_name = module.cluster.cluster_name

  oidc_issuer_url = module.cluster.oidc_issuer_url

}

