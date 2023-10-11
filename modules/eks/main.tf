
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

resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {

    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]

    subnet_ids = [
      aws_subnet.private-1a.id,
      aws_subnet.private-1b.id,
      aws_subnet.public-1a.id,
      aws_subnet.public-1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.amazon-eks-cluster-policy]
}


data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.cluster.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate" {
  value = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
}

output "auth_token" {
  value = data.aws_eks_cluster_auth.eks.token
}

resource "aws_eks_fargate_profile" "kube-system" {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "kube-system"
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn

  subnet_ids = [
    aws_subnet.private-1a.id,
    aws_subnet.private-1b.id
  ]

  selector {
    namespace = "kube-system"
  }
}

resource "null_resource" "k8s_patcher" {
  depends_on = [aws_eks_fargate_profile.kube-system]

  triggers = {
    endpoint = aws_eks_cluster.cluster.endpoint
    ca_crt   = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
    token    = data.aws_eks_cluster_auth.eks.token
  }

  provisioner "local-exec" {
    command = <<EOH
cat >/tmp/ca.crt <<EOF
${base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)}
EOF
kubectl \
  --server="${aws_eks_cluster.cluster.endpoint}" \
  --certificate_authority=/tmp/ca.crt \
  --token="${data.aws_eks_cluster_auth.eks.token}" \
  patch deployment coredns \
  -n kube-system --type json \
  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations/eks.amazonaws.com~1compute-type"}]'
EOH
  }

  lifecycle {
    ignore_changes = [triggers]
  }
}

resource "aws_eks_fargate_profile" "prod" {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = var.namespace
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn

  subnet_ids = [
    aws_subnet.private-1a.id,
    aws_subnet.private-1b.id
  ]

  selector {
    namespace = var.namespace
  }
}
