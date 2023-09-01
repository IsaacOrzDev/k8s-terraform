variable "region" {
  type    = string
  default = "us-west-1"
}

variable "profile" {
  type    = string
  default = null
}

variable "registry_server" {
  type = string
}

variable "registry_password" {
  type      = string
  sensitive = true
}

variable "mqtt_username" {
  type      = string
  sensitive = true
}

variable "mqtt_password" {
  type      = string
  sensitive = true
}
