module "ecr-repo" {
  source   = "../modules/ecr"
  ecr_name = ["custom-mqtt-server", "mqtt-tester", "demo-system-api"]
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
    "mqtt-server-deployment" = {
      containers = {
        "mqtt-server" = {
          image = "${var.registry_server}/custom-mqtt-server"
          port  = 1883
          env_variables = {
            "USERNAME" = var.mqtt_username
            "PASSWORD" = var.mqtt_password
          }
        }
        "mqtt-tester" = {
          image = "${var.registry_server}/mqtt-tester"
          env_variables = {
            "MQTT_URL"      = "mqtt://localhost:1883"
            "MQTT_USERNAME" = var.mqtt_username
            "MQTT_PASSWORD" = var.mqtt_password
          }
        }
      }
      service = {
        name = "mqtt-server-service"
        port = [1883, 1883]
      }
    }

    "api-deployment" = {
      containers = {
        "api" = {
          image = "${var.registry_server}/demo-system-api"
          port  = 3000
          env_variables = {
            "MQTT_URL"      = "mqtt://mqtt-server-service:1883"
            "MQTT_USERNAME" = var.mqtt_username
            "MQTT_PASSWORD" = var.mqtt_password
          }
        }

      }
      service = {
        name = "api-service"
        port = [3000]
      }
    }
  }

  ingress = {
    name = "demo-system"
    paths = [{
      service = "api-service"
    }]
  }
}

output "k8s-config" {
  value = module.k8s-config
}
