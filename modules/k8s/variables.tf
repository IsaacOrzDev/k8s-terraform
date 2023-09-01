variable "namespace" {
  type = string
}

variable "context" {
  type    = string
  default = null
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
      port              = number
      port_protocol     = optional(string)
      env_variables     = optional(map(string))
    }))
    service = optional(object({
      port          = list(number)
      port_protocol = optional(string)
    }))
  }))
}

variable "ingress" {
  type = object({
    name = string
    paths = list(object({
      path    = optional(string)
      service = string
      port    = number
    }))
  })

  default = null
}
