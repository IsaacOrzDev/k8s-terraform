module "k8s-config" {
  source = "../modules/k8s"


  namespace = "sketch-blend"
  context   = "minikube"

  registry_server   = var.registry_server
  registry_password = var.registry_password


  deployments = {
    "api-deployment" = {
      containers = {

        "api" = {
          image = "${var.registry_server}/sketch-blend-api-module:latest"
          port  = 3000
          resources = {
            cpu    = ["200m", "1200m"]
            memory = ["300Mi", "1024Mi"]
          }

          liveness_probe = {
            http_get = {
              path = "/"
            }
          }



          env_variables = {
            "GOOGLE_CLIENT_ID"                = var.google_client_id
            "GOOGLE_CLIENT_SECRET"            = var.google_client_secret
            "GITHUB_CLIENT_ID"                = var.github_client_id
            "GITHUB_CLIENT_SECRET"            = var.github_client_secret
            "AWS_ACCESS_KEY_ID_FOR_EMAIL"     = var.aws_access_key_for_email
            "AWS_SECRET_ACCESS_KEY_FOR_EMAIL" = var.aws_secret_access_key_for_email
            "AWS_ACCESS_KEY_ID_FOR_S3"        = var.aws_access_key_for_s3
            "AWS_SECRET_ACCESS_KEY_FOR_S3"    = var.aws_secret_access_key_for_s3
            "SENDER_EMAIL"                    = var.sender_email
            "SNS_TOPIC_ARN"                   = var.sns_topic_arn
            "DATABASE_URL"                    = var.mongodb_url
            "API_URL"                         = var.api_url
            "PORTAL_URL"                      = var.portal_url
            "USER_MODULE_URL"                 = "user-service:5008"
            "GENERATOR_MODULE_URL"            = "generator-service:5002"
            "DOCUMENT_MODULE_URL"             = "document-service:5003"
            "S3_IMAGE_BUCKET_NAME"            = "sketch-blend-images"
            "IMAGES_URL"                      = var.images_url
            "SENTRY_DNS"                      = var.sentry_dns
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
          liveness_probe = {
            grpc = {}
          }
          resources = {
            cpu    = ["200m", "800m"]
            memory = ["300Mi", "1024Mi"]
          }
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
          liveness_probe = {
            grpc = {}
          }
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
          liveness_probe = {
            grpc = {}
          }

          env_variables = {
            "PORT"                = 5002
            "REPLICATE_API_TOKEN" = var.repliate_api_token
            "SCRIBBLE_MODEL"      = var.scribble_model
            "BLIP_MODEL"          = var.blip_model
            "N_PROMPT"            = var.negative_prompt
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
    name = "sketch-blend"
    paths = [{
      service = "api-service"
    }]
  }
}

output "k8s-config" {
  value = module.k8s-config
}
