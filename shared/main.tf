module "ecr-repo" {
  source = "../modules/ecr"
  ecr_name = [
    "sketch-blend-api-module",
    "sketch-blend-user-module",
    "sketch-blend-generator-module",
    "sketch-blend-document-module",
  ]
  region                              = var.region
  profile                             = var.profile
  arn_of_identity_provider_for_github = var.arn_of_identity_provider_for_github
  github_username                     = var.github_username
}

output "ecr-repo" {
  value = module.ecr-repo
}

module "s3" {
  source  = "../modules/s3"
  region  = var.region
  profile = var.profile

  bucket_name = "sketch-blend-images"
}

output "s3" {
  value     = module.s3
  sensitive = true
}
