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

