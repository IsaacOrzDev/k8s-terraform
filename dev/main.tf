module "ecr-repo" {
  source   = "../modules/ecr"
  ecr_name = var.ecr_name
  region   = var.region
  profile  = var.profile
}

output "ecr-repo" {
  value = module.ecr-repo
}

module "k8s-config" {
  source = "../modules/k8s"

  namespace = "demo-system"
  context   = "docker-desktop"
}
