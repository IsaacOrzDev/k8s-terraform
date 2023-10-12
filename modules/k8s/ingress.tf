resource "kubernetes_ingress_v1" "ingress" {

  metadata {
    name      = "${var.ingress.name}-ingress"
    namespace = var.namespace
    annotations = var.is_aws ? {
      "kubernetes.io/ingress.class"           = "alb"
      "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/listen-ports" = var.ingress.domain_name != null ? jsonencode([{
        "HTTP" = 80
        }, {
        "HTTPS" = 443
      }]) : null
      "alb.ingress.kubernetes.io/actions.ssl-redirect" = var.ingress.domain_name != null ? jsonencode({
        "Type" = "redirect"
        "RedirectConfig" = {
          "Protocol"   = "HTTPS"
          "Port"       = "443"
          "StatusCode" = "HTTP_301"
        }
      }) : null
      "alb.ingress.kubernetes.io/certificate-arn" = var.ingress.certificate_arn != null ? var.ingress.certificate_arn : null
      "alb.ingress.kubernetes.io/ssl-redirect"    = var.ingress.domain_name != null ? "443" : null
      "alb.ingress.kubernetes.io/group.name" : "${var.ingress.name}-ingress"
      } : {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

  spec {
    ingress_class_name = var.is_aws ? "alb" : "nginx"
    rule {
      host = var.ingress.domain_name != null ? var.ingress.domain_name : null
      http {
        dynamic "path" {
          for_each = var.ingress.paths

          content {
            path      = path.value.path != null ? path.value.path : "/"
            path_type = path.value.path_type != null ? path.value.path_type : "Prefix"
            backend {
              service {
                name = path.value.service
                port {
                  number = path.value.port != null ? path.value.port : 80
                }
              }
            }
          }
        }
      }
    }


    dynamic "rule" {
      for_each = var.ingress.domain_name != null ? [1] : []

      content {
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = "ssl-redirect"
                port {
                  name = "use-annotation"
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

output "ingress" {
  value = var.ingress != null ? [for i, item in var.ingress.paths : { path = item.path != null ? item.path : "/", service = "${item.service}-service" }] : null

}
