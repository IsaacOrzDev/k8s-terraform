variable "region" {
  type    = string
  default = "us-west-1"
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
