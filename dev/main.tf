module "ecr-repo" {
  source   = "../modules/ecr"
  ecr_name = ["custom-mqtt-server"]
  region   = var.region
  profile  = var.profile
}

output "ecr-repo" {
  value = module.ecr-repo
}

module "k8s-config" {
  source = "../modules/k8s"

  namespace = "demo-system"
  context   = "minikube"

  registry_server   = var.registry_server
  registry_password = var.registry_password

  deployments = {
    "mqtt-server" = {
      containers = {
        "mqtt-server" = {
          image = "${var.registry_server}/custom-mqtt-server"
          port  = 1883
        }
      }
    }
    "nginx" = {
      containers = {
        "nginx" = {
          image = "nginx"
          port  = 80
        }
      }
      service = {
        port = [80]
      }
    }
  }

  ingress = {
    name = "demo-system"
    paths = [{
      service = "nginx"
      port    = 80
    }]
  }
}
