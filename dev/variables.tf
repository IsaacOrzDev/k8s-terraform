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

variable "google_client_id" {
  type      = string
  sensitive = true
}

variable "google_client_secret" {
  type      = string
  sensitive = true
}

variable "jwt_secret_key" {
  type      = string
  sensitive = true
}

variable "arn_of_identity_provider_for_github" {
  type    = string
  default = null
}
