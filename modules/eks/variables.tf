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

variable "namespace" {
  type = string
}
