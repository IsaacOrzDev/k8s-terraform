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

  vpc = {
    cidr_block = "10.0.0.0/16"
    private_subnets = [{
      cidr_block = "10.0.0.0/19"
      }, {
      cidr_block = "10.0.32.0/19"
    }]
    public_subnets = [{
      cidr_block = "10.0.64.0/19"
      }, {
      cidr_block = "10.0.96.0/19"
    }]
  }

  namespace       = "demo-system-prod"
  sub_domain_name = "demo-system-k8s"
  domain_name     = var.domain_name
}

output "eks" {
  value = {
    vpc_id = module.eks.vpc_id
  }
}

module "k8s-config" {
  source = "../modules/k8s"

  cluster_config = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = module.eks.cluster_certificate
    token                  = module.eks.auth_token
  }

  is_aws          = true
  registry_server = var.registry_server

  namespace = "demo-system-prod"

  ingress = {
    domain_name     = "demo-system-k8s.${var.domain_name}"
    certificate_arn = module.eks.certificate_arn
    name            = "demo-system"
    paths = [{
      path      = "/*"
      path_type = "ImplementationSpecific"
      service   = "nginx-service"
      port      = 80
    }]
  }

  # ingress = null
}
