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

  default = null
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
      port              = optional(number)
      port_protocol     = optional(string)
      env_variables     = optional(map(string))
    }))
    service = optional(object({
      name          = string
      port          = list(number)
      port_protocol = optional(string)
    }))
  }))

  default = {
    "nginx-deployment" = {
      containers = {
        "nginx" = {
          image = "nginx"
          port  = 80
        }
      }
      service = {
        name = "nginx-service"
        port = [80]
      }
    }
  }
}

variable "ingress" {
  type = object({
    name = string
    paths = list(object({
      path    = optional(string)
      service = string
      port    = optional(number)
    }))
  })

  default = {
    name = "demo-system"
    paths = [{
      service = "nginx-service"
    }]
  }
}

variable "cluster_config" {
  type = object({
    host                   = optional(string)
    cluster_ca_certificate = optional(string)
    token                  = optional(string)
  })

  default = {
    host                   = null
    cluster_ca_certificate = null
    token                  = null
  }
}

variable "is_aws" {
  type    = bool
  default = false
}

