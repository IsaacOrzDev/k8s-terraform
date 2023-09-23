module "ecr-repo" {
  source = "../modules/ecr"
  ecr_name = [
    "custom-mqtt-server",
    "demo-system-api",
    "demo-system-auth",
    "demo-system-user-module",
    "demo-system-generator-module",
    "demo-system-document-module",
  ]
  region                              = var.region
  profile                             = var.profile
  arn_of_identity_provider_for_github = var.arn_of_identity_provider_for_github
  github_username                     = var.github_username
}

output "ecr-repo" {
  value = module.ecr-repo
}

module "ecs" {
  arn_of_identity_provider_for_github = var.arn_of_identity_provider_for_github
  github_username                     = var.github_username

  source  = "../modules/ecs"
  region  = var.region
  profile = var.profile
  name    = "demo-system"


  domain_name     = var.domain_name
  sub_domain_name = "demo-system"

  cpu           = 256
  memory        = 512
  service_count = 1

  container_definitions = [
    {
      name      = "api-module"
      image     = "${var.registry_server}/demo-system-api:latest"
      essential = true
      ports     = [3000, 3000]
      environment = {
        "IS_MICROSERVICE"       = true
        "MQTT_URL"              = "mqtt://localhost:1883"
        "MQTT_USERNAME"         = var.mqtt_username
        "MQTT_PASSWORD"         = var.mqtt_password
        "GOOGLE_CLIENT_ID"      = var.google_client_id
        "GOOGLE_CLIENT_SECRET"  = var.google_client_secret
        "GITHUB_CLIENT_ID"      = var.github_client_id
        "GITHUB_CLIENT_SECRET"  = var.github_client_secret
        "AWS_ACCESS_KEY_ID"     = var.aws_access_key
        "AWS_SECRET_ACCESS_KEY" = var.aws_secret_access_key
        "SENDER_EMAIL"          = var.sender_email
        "SNS_TOPIC_ARN"         = var.sns_topic_arn
        "DATABASE_URL"          = var.mongodb_url
        "PORTAL_URL"            = var.portal_url
        "SUB_SERVICE_PORT"      = "localhost:5008"
      }
    },
    {
      name  = "mqtt-server"
      image = "${var.registry_server}/custom-mqtt-server:latest"
      ports = [1883, 1883]
      environment = {
        "USERNAME" = var.mqtt_username
        "PASSWORD" = var.mqtt_password
      }
    },
    {
      name  = "auth"
      image = "${var.registry_server}/demo-system-auth:latest"
      # essential = true
      ports = [8000, 8000]
      environment = {
        "MQTT_HOST"      = "localhost"
        "MQTT_PORT"      = 1883
        "MQTT_USERNAME"  = var.mqtt_username
        "MQTT_PASSWORD"  = var.mqtt_password
        "JWT_SECRET_KEY" = var.jwt_secret_key
      }
    },
    {
      name  = "user-module"
      image = "${var.registry_server}/demo-system-user-module:latest"
      # essential = true
      ports = [5008, 5008],
      environment = {
        "CONNECTION_STRING" = var.postgresql_connection_string
      }
    }
  ]

  load_balancer = {
    container_name = "api-module"
    port           = 3000
  }
}

output "ecs" {
  value = module.ecs
}
