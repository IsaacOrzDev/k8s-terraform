terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

}

provider "aws" {
  region = var.region
}

module "ecr-repo" {
  source   = "../modules/ecr"
  ecr_name = var.ecr_name
  region   = var.region
}

output "erc_name" {
  value = module.ecr-repo.erc_name
}

output "erc_arn" {
  value = module.ecr-repo.erc_arn
}
