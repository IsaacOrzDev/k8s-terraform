variable "region" {
  type = string
}

variable "profile" {
  type    = string
  default = null
}

variable "container_definitions" {
  type = list(object({
    name  = string
    image = string
    portMappings = list(object({
      containerPort = number
      hostPort      = number
    }))
    essential = optional(bool)
    environment = optional(list(object({
      name  = string
      value = string
    })))
  }))
}
