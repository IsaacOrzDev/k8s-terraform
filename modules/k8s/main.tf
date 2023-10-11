terraform {
  required_version = ">= 0.13"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "kubernetes" {
  config_path    = var.cluster_config.host == null ? "~/.kube/config" : null
  config_context = var.context

  host                   = var.cluster_config.host
  cluster_ca_certificate = var.cluster_config.cluster_ca_certificate
  token                  = var.cluster_config.token
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = var.context
}

resource "kubernetes_namespace" "namespace" {

  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "aws_ecr_secret" {
  metadata {
    namespace = var.namespace
    name      = local.aws_ecr_secret_name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = "AWS"
          "password" = var.registry_password
          "auth"     = base64encode("AWS:${var.registry_password}")
        }
      }
    })
  }

  count = var.registry_password != null ? 1 : 0
}

