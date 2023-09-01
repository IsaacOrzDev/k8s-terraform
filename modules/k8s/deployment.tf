resource "kubernetes_deployment" "deployment" {

  for_each = var.deployments

  metadata {
    namespace = var.namespace
    name      = "${each.key}-deployment"
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "${each.key}-deployment"
      }
    }

    template {
      metadata {
        labels = {
          app = "${each.key}-deployment"
        }
      }

      spec {
        dynamic "container" {
          for_each = each.value.containers

          content {
            name  = container.key
            image = container.value.image

            image_pull_policy = try(container.image_pull_policy, "Always")

            port {
              container_port = container.value.port
              protocol       = try(container.value.port_protocol, "TCP")
            }

            dynamic "env" {
              for_each = try(container.value.env_variables, {}) != null ? container.value.env_vars : {}
              content {
                name  = name.key
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
