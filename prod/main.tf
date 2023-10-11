# module "ecr-repo" {
#   source                              = "../modules/ecr"
#   ecr_name                            = ["custom-mqtt-server", "mqtt-tester", "demo-system-api", "demo-system-auth"]
#   region                              = var.region
#   profile                             = var.profile
#   arn_of_identity_provider_for_github = var.arn_of_identity_provider_for_github
# }


module "eks" {
  source       = "../modules/eks"
  region       = var.region
  cluster_name = "demo_system"
  namespace    = "demo-system-prod"
}

output "eks" {
  value = {
    vpc_id = module.eks.vpc_id
  }
}

module "k8s-config" {
  source = "../modules/k8s"

  namespace = "demo-system-prod"

  is_aws          = true
  registry_server = var.registry_server

  cluster_config = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = module.eks.cluster_certificate
    token                  = module.eks.auth_token
  }

  # ingress = null
}
