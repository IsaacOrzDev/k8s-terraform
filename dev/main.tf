module "ecr-repo" {
  source                              = "../modules/ecr"
  ecr_name                            = ["custom-mqtt-server", "mqtt-tester", "demo-system-api", "demo-system-auth"]
  region                              = var.region
  profile                             = var.profile
  arn_of_identity_provider_for_github = var.arn_of_identity_provider_for_github
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
        # "mqtt-tester" = {
        #   image = "${var.registry_server}/mqtt-tester"
        #   env_variables = {
        #     "MQTT_URL"      = "mqtt://localhost:1883"
        #     "MQTT_USERNAME" = var.mqtt_username
        #     "MQTT_PASSWORD" = var.mqtt_password
        #   }
        # }
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
            "MQTT_URL"              = "mqtt://mqtt-server-service:1883"
            "MQTT_USERNAME"         = var.mqtt_username
            "MQTT_PASSWORD"         = var.mqtt_password
            "GOOGLE_CLIENT_ID"      = var.google_client_id
            "GOOGLE_CLIENT_SECRET"  = var.google_client_secret
            "AWS_ACCESS_KEY_ID"     = var.aws_access_key
            "AWS_SECRET_ACCESS_KEY" = var.aws_secret_access_key
            "SENDER_EMAIL"          = var.sender_email
            "SNS_TOPIC_ARN"         = var.sns_topic_arn
          }
        }
        "auth" = {
          image = "${var.registry_server}/demo-system-auth"
          port  = 8000
          env_variables = {
            "MQTT_HOST"      = "mqtt-server-service"
            "MQTT_PORT"      = 1883
            "MQTT_USERNAME"  = var.mqtt_username
            "MQTT_PASSWORD"  = var.mqtt_password
            "JWT_SECRET_KEY" = var.jwt_secret_key
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
