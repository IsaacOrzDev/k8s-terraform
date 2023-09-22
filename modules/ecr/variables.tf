variable "ecr_name" {
  type = list(string)
}

variable "image_mutability" {
  type    = string
  default = null
}

variable "encrypt_type" {
  type    = string
  default = "AES256"
}

variable "region" {
  type = string
}

variable "profile" {
  type    = string
  default = null
}

variable "arn_of_identity_provider_for_github" {
  type    = string
  default = null
}

variable "github_username" {
  type    = string
  default = null
}


