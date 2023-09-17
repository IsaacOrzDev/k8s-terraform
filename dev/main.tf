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


// make it correct please 
locals {
  api_env_variables = [for k, v in {
    "IS_MICROSERVICE"       = true
    "MQTT_URL"              = "mqtt://localhost:1883"
    "MQTT_USERNAME"         = var.mqtt_username
    "MQTT_PASSWORD"         = var.mqtt_password
    "GOOGLE_CLIENT_ID"      = var.google_client_id
    "GOOGLE_CLIENT_SECRET"  = var.google_client_secret
    "AWS_ACCESS_KEY_ID"     = var.aws_access_key
    "AWS_SECRET_ACCESS_KEY" = var.aws_secret_access_key
    "SENDER_EMAIL"          = var.sender_email
    "SNS_TOPIC_ARN"         = var.sns_topic_arn
    } : {
    name  = k
    value = v
    }
  ]

  mqtt_server_env_variables = [for k, v in {
    "USERNAME" = var.mqtt_username
    "PASSWORD" = var.mqtt_password
    } : {
    name  = k
    value = v
    }
  ]

  auth_env_variables = [for k, v in {
    "MQTT_HOST"      = "localhost"
    "MQTT_PORT"      = 1883
    "MQTT_USERNAME"  = var.mqtt_username
    "MQTT_PASSWORD"  = var.mqtt_password
    "JWT_SECRET_KEY" = var.jwt_secret_key
    } : {
    name  = k
    value = v
    }
  ]
}

module "ecs" {
  source  = "../modules/ecs"
  region  = var.region
  profile = var.profile
  # container_definitions = <<DEFINITION
  # [
  #   {
  #     "name": "demo-system-task",
  #     "image": "${var.registry_server}/demo-system-api:latest",
  #     "essential": true,
  #     "portMappings": [
  #       {
  #         "containerPort": 3000,
  #         "hostPort": 3000
  #       }
  #     ],
  #     "environment": [
  #       {

  #       }
  #     ]
  #   }
  # ]
  # DEFINITION
  container_definitions = [
    {
      name      = "demo-system-task"
      image     = "${var.registry_server}/demo-system-api:latest"
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
      environment = local.api_env_variables
    },
    {
      name      = "mqtt-server"
      image     = "${var.registry_server}/custom-mqtt-server:latest"
      essential = true
      portMappings = [
        {
          containerPort = 1883
          hostPort      = 1883
        }
      ]
      environment = local.mqtt_server_env_variables
    },
    {
      name      = "auth"
      image     = "${var.registry_server}/demo-system-auth:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      environment = local.auth_env_variables
    }
  ]
}

output "ecs" {
  value = module.ecs
}
