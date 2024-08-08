variable "region" {
  type = string
}

variable "profile" {
  type    = string
  default = null
}

variable "cluster_name" {
  type        = string
  description = "name to describe your eks cluster"
}

variable "namespaces" {
  type = set(string)
}

variable "domain_name" {
  type    = string
  default = null
}

variable "vpc" {
  type = object({
    cidr_block = string
    private_subnets = list(object({
      cidr_block = string
    }))
    public_subnets = list(object({
      cidr_block = string
    }))
  })
}
