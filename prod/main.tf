module "eks" {
  source       = "../modules/eks"
  region       = var.region
  cluster_name = "sketch_blend"

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

  namespace       = "sketch-blend"
  sub_domain_name = "sketch-blend-api"
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

  namespace = "sketch-blend"

  deployments = {
    "api-deployment" = {
      containers = {
        "api" = {
          image = "${var.registry_server}/sketch-blend-api-module:latest"
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
          image = "${var.registry_server}/sketch-blend-user-module:latest"
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
          image = "${var.registry_server}/sketch-blend-document-module:latest"
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
          image = "${var.registry_server}/sketch-blend-generator-module:latest"
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
    domain_name     = "sketch-blend-api.${var.domain_name}"
    certificate_arn = module.eks.certificate_arn
    name            = "sketch-blend"
    paths = [{
      path      = "/*"
      path_type = "ImplementationSpecific"
      service   = "api-service"
      port      = 80
    }]
  }

  # ingress = null
}
