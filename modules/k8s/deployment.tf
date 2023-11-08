resource "kubernetes_deployment" "deployment" {

  for_each = var.deployments

  metadata {
    namespace = var.namespace
    name      = each.key
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${each.key}"
      }
    }

    template {
      metadata {
        labels = {
          app = "${each.key}"
        }
      }

      spec {
        dynamic "container" {
          for_each = each.value.containers

          content {
            name  = container.key
            image = container.value.image

            image_pull_policy = try(container.image_pull_policy, "Always")

            dynamic "liveness_probe" {
              for_each = container.value.liveness_probe != null ? [container.value.liveness_probe] : []

              content {
                dynamic "http_get" {
                  for_each = liveness_probe.value.http_get != null ? [liveness_probe.value.http_get] : []

                  content {
                    path = try(http_get.value.path, "/")
                    port = try(container.value.port, 80)
                  }
                }

                dynamic "grpc" {
                  for_each = liveness_probe.value.grpc != null ? [liveness_probe.value.grpc] : []

                  content {
                    port = try(container.value.port, 80)
                  }
                }

                initial_delay_seconds = liveness_probe.value.initial_delay_seconds != null ? liveness_probe.value.initial_delay_seconds : 30
                period_seconds        = 10
                timeout_seconds       = 5
                failure_threshold     = 3
              }
            }

            dynamic "port" {
              for_each = container.value.port != null ? [container.value.port] : []
              content {
                container_port = port.value
                protocol       = try(container.value.port_protocol, "TCP")
              }
            }

            dynamic "env" {
              for_each = try(container.value.env_variables, {}) != null ? container.value.env_variables : {}
              content {
                name  = env.key
                value = env.value
              }
            }

            resources {
              requests = {
                cpu    = try(container.value.resources.cpu[0], local.default_cpu_resource)
                memory = try(container.value.resources.memory[0], local.default_memory_resource)
              }


              limits = {
                cpu = try(
                  container.value.resources.cpu[1],
                  try(container.value.resources.cpu[0], local.default_cpu_resource)
                )
                memory = try(
                  container.value.resources.memory[1],
                  try(container.value.resources.memory[0], local.default_memory_resource)
                )
              }
            }
          }
        }

        image_pull_secrets {
          name = local.aws_ecr_secret_name
        }
      }
    }
  }

}

output "deployments" {
  value = [for i, item in kubernetes_deployment.deployment : item.metadata[0].name]
}
