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


variable "github_client_id" {
  type      = string
  sensitive = true
}

variable "github_client_secret" {
  type      = string
  sensitive = true
}


variable "jwt_secret_key" {
  type      = string
  sensitive = true
}

variable "mongodb_url" {
  type      = string
  sensitive = true
}

variable "postgresql_connection_string" {
  type      = string
  sensitive = true
}

variable "arn_of_identity_provider_for_github" {
  type    = string
  default = null
}

variable "aws_access_key_for_email" {
  type    = string
  default = null
}

variable "aws_secret_access_key_for_email" {
  type    = string
  default = null
}

variable "aws_access_key_for_s3" {
  type    = string
  default = null
}

variable "aws_secret_access_key_for_s3" {
  type    = string
  default = null
}

variable "sender_email" {
  type    = string
  default = null
}

variable "sns_topic_arn" {
  type    = string
  default = null
}

variable "domain_name" {
  type = string
}

variable "api_url" {
  type = string
}

variable "portal_url" {
  type = string
}

variable "images_url" {
  type = string
}

variable "github_username" {
  type    = string
  default = null
}

variable "repliate_api_token" {
  type      = string
  sensitive = true
}


variable "scribble_model" {
  type      = string
  sensitive = true
}

variable "blip_model" {
  type      = string
  sensitive = true
}
