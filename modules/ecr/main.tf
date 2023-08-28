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

resource "aws_ecr_repository" "ecr" {
  for_each = toset(var.ecr_name)

  name                 = each.key
  image_tag_mutability = var.image_mutability

  encryption_configuration {
    encryption_type = var.encrypt_type
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "erc_name" {
  value = [for i, ecr in aws_ecr_repository.ecr : ecr.name]
}

output "erc_arn" {
  value = [for i, ecr in aws_ecr_repository.ecr : ecr.arn]
}

