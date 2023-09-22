resource "aws_iam_role" "ecr_push_role" {
  for_each = var.arn_of_identity_provider_for_github != null ? toset(var.ecr_name) : []
  name     = "${each.value}-ecr-push-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecr.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
          "Federated": "${var.arn_of_identity_provider_for_github}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
          "ForAllValues:StringEquals": {
              "token.actions.githubusercontent.com:iss": "https://token.actions.githubusercontent.com",
              "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
          },
          "StringLike": {
              "token.actions.githubusercontent.com:sub": "repo:${var.github_username}/*:*"
          }
      }
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecr_push_policy" {
  for_each    = var.arn_of_identity_provider_for_github != null ? toset(var.ecr_name) : []
  name        = "${each.value}-ecr-push-policy"
  description = "Allows pushing images to ECR ${each.value}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:CompleteLayerUpload",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart"
      ],
      "Resource": "arn:aws:ecr:${var.region}:*:repository/${each.value}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecr_role_attachment" {
  for_each   = var.arn_of_identity_provider_for_github != null ? toset(var.ecr_name) : []
  role       = aws_iam_role.ecr_push_role[each.value].name
  policy_arn = aws_iam_policy.ecr_push_policy[each.value].arn
}

output "ecr_push_role" {
  value = [for i, ecr in aws_iam_role.ecr_push_role : {
    name = i
    arn  = ecr.arn
  }]
}
