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

  registry_server   = var.registry_server
  registry_password = var.registry_password

  deployments = {
    "mqtt-server" = {
      containers = {
        "mqtt-server" = {
          image = "${var.registry_server}/custom-mqtt-server"
          port  = [1883]
        }
      }
    }
  }
}
