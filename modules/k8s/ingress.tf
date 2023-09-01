resource "kubernetes_ingress_v1" "ingress" {

  metadata {
    name      = "${var.ingress.name}-ingress"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    rule {
      http {
        dynamic "path" {
          for_each = var.ingress.paths

          content {
            path      = path.value.path != null ? path.value.path : "/"
            path_type = "Prefix"
            backend {
              service {
                name = "${path.value.service}-service"
                port {
                  number = path.value.port
                }
              }
            }
          }
        }
      }
    }
  }

  count = var.ingress != null ? 1 : 0
}
