variable "namespace" {
  type = string
}

variable "context" {
  type    = string
  default = "docker-desktop"
}

variable "registry_server" {
  type = string
}

variable "registry_password" {
  type = string
}

variable "deployments" {
  type = map(object({
    containers = map(object({
      resources = optional(object({
        cpu    = list(string)
        memory = list(string)
      }))
      image             = string
      image_pull_policy = optional(string)
      port              = list(number)
      env_variables     = optional(map(string))
    }))
  }))
}
