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

  deployments = {
    "api-deployment" = {
      containers = {
        "api" = {
          image = "${var.registry_server}/demo-system-api"
          port  = 3000
          env_variables = {
            "GOOGLE_CLIENT_ID"                = var.google_client_id
            "GOOGLE_CLIENT_SECRET"            = var.google_client_secret
            "GITHUB_CLIENT_ID"                = var.github_client_id
            "GITHUB_CLIENT_SECRET"            = var.github_client_secret
            "AWS_ACCESS_KEY_ID_FOR_EMAIL"     = var.aws_access_key_for_email
            "AWS_SECRET_ACCESS_KEY_FOR_EMAIL" = var.aws_secret_access_key_for_email
            "SENDER_EMAIL"                    = var.sender_email
            "SNS_TOPIC_ARN"                   = var.sns_topic_arn
            "DATABASE_URL"                    = var.mongodb_url
            "API_URL"                         = var.api_url
            "PORTAL_URL"                      = var.portal_url
            "USER_MODULE_URL"                 = "user-service:5008"
            "GENERATOR_MODULE_URL"            = "generator-service:5002"
            "DOCUMENT_MODULE_URL"             = "document-service:5003"
          }
        }

      }
      service = {
        name = "api-service"
        port = [3000]
      }
    },
    "user-deployment" = {
      containers = {
        "user" = {
          image = "${var.registry_server}/demo-system-user-module:latest"
          port  = 5008
          env_variables = {
            "CONNECTION_STRING" = var.postgresql_connection_string
          }
        }

      },
      service = {
        name = "user-service"
        port = [5008, 5008]
      }
    },
    "document-deployment" = {
      containers = {
        "document" = {
          image = "${var.registry_server}/demo-system-document-module:latest"
          port  = 5003
          env_variables = {
            "DATABASE_URL" = var.mongodb_url
          }
        }
      },
      service = {
        name = "document-service"
        port = [5003, 5003]
      }
    },
    "generator-deployment" = {
      containers = {
        "generator" = {
          image = "${var.registry_server}/demo-system-generator-module:latest"
          port  = 5002
          env_variables = {
            "PORT"                = 5002
            "REPLICATE_API_TOKEN" = var.repliate_api_token
            "SCRIBBLE_MODEL"      = var.scribble_model
            "BLIP_MODEL"          = var.blip_model
          }
        }
      },
      service = {
        name = "generator-service"
        port = [5002, 5002]
      }
    },
  }

  ingress = {
    domain_name     = "demo-system-k8s.${var.domain_name}"
    certificate_arn = module.eks.certificate_arn
    name            = "demo-system"
    paths = [{
      path      = "/*"
      path_type = "ImplementationSpecific"
      service   = "api-service"
      port      = 80
    }]
  }

  # ingress = null
}
