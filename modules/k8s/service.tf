resource "kubernetes_service" "service" {
  for_each = { for name, deployment in var.deployments : name => deployment if deployment.service != null }

  metadata {
    name      = "${each.key}-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "${each.key}-deployment"
    }

    port {
      name        = "http"
      protocol    = "TCP"
      port        = 80
      target_port = each.value.service.port
    }
  }

}
