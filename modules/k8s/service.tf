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
      protocol    = try(each.value.service.port_protocol, "TCP")
      port        = try(each.value.service.port[1], 80)
      target_port = each.value.service.port[0]
    }
  }

}

output "services" {
  value = [for i, item in kubernetes_service.service : item.metadata[0].name]
}
