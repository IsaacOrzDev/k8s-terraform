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
