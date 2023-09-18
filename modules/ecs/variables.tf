variable "region" {
  type = string
}

variable "profile" {
  type    = string
  default = null
}

variable "name" {
  type        = string
  description = "name to describe your ecs cluster"
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

variable "load_balancer" {
  type = object({
    container_name = string
    port           = number
  })
}

variable "domain_name" {
  type = string
}

variable "sub_domain_name" {
  type = string
}

variable "cpu" {
  type    = number
  default = 256
}

variable "memory" {
  type    = number
  default = 512
}

variable "service_count" {
  type    = number
  default = 1
}
