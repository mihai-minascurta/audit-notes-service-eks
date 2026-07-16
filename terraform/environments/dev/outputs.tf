output "ebs_csi_role_arn" {
  value = module.ebs_csi
}

output "alb_controller_role_arn" {
  value = module.alb_controller.alb_controller_role_arn
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "cluster_name" {
  value = module.cluster.cluster_name
}