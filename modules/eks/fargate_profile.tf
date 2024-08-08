resource "aws_iam_role" "eks-fargate-profile" {
  name = "eks-fargate-profile"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = ["eks.amazonaws.com", "eks-fargate-pods.amazonaws.com"]
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks-fargate-profile" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks-fargate-profile.name
}

resource "aws_iam_role_policy_attachment" "eks-fargate-profile-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-fargate-profile.name
}

resource "aws_iam_role_policy_attachment" "eks-fargate-profile-controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-fargate-profile.name
}


data "tls_certificate" "eks" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_eks_fargate_profile" "prod" {
  for_each = var.namespaces

  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = each.value
  pod_execution_role_arn = aws_iam_role.eks-fargate-profile.arn

  subnet_ids = [
    aws_subnet.private-1a.id,
    aws_subnet.private-1b.id
  ]

  selector {
    namespace = each.value
  }
}
