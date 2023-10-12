
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }


  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
}

provider "kubernetes" {

  host                   = aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster.id]
      command     = "aws"
    }
  }
}
