module "ecr-repo" {
  source = "../modules/ecr"
  ecr_name = [
    "demo-system-api",
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
        "USER_MODULE_URL"       = "localhost:5008"
        "GENERATOR_MODULE_URL"  = "localhost:5002"
        "DOCUMENT_MODULE_URL"   = "localhost:5003"
      }
    },
    {
      name  = "user-module"
      image = "${var.registry_server}/demo-system-user-module:latest"
      ports = [5008, 5008]
      environment = {
        "CONNECTION_STRING" = var.postgresql_connection_string
      }
    },
    {
      name  = "generator-module"
      image = "${var.registry_server}/demo-system-generator-module:latest"
      ports = [5002, 5002]
      environment = {
        "PORT"                = 5002
        "REPLICATE_API_TOKEN" = var.repliate_api_token
        "REPLICATE_MODEL"     = "stability-ai/stable-diffusion:27b93a2413e7f36cd83da926f3656280b2931564ff050bf9575f1fdf9bcd7478"
      }
    },
    {
      name  = "document-module"
      image = "${var.registry_server}/demo-system-document-module:latest"
      ports = [5003, 5003]
      environment = {
        "DATABASE_URL" = var.mongodb_url
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
