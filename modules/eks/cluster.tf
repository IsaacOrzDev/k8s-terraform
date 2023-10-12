
resource "aws_iam_role" "eks-cluster" {
  name = "eks-cluster-${var.cluster_name}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "amazon-eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
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
