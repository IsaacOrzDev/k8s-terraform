provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.context
}

resource "kubernetes_namespace" "namespace" {

  metadata {
    name = var.namespace
  }
}
