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

# resource "aws_iam_role" "ecr_push_role" {
#   for_each = toset(var.ecr_name)
#   name = "${each.value}-ecr-push-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ecr.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

resource "aws_iam_policy" "ecr_push_policy" {
  for_each = toset(var.ecr_name)
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

resource "aws_iam_user" "ecr_user" {
  for_each = toset(var.ecr_name)
  name = "${each.value}-ecr-cicd-user"
}

resource "aws_iam_user_policy_attachment" "ecr_user_attachment" {
  for_each = toset(var.ecr_name)
  user       = aws_iam_user.ecr_user[each.value].name
  policy_arn = aws_iam_policy.ecr_push_policy[each.value].arn
}

# resource "aws_iam_role_policy_attachment" "ecr_role_attachment" {
#   for_each = toset(var.ecr_name)
#   role       = aws_iam_role.ecr_push_role[each.value].name
#   policy_arn = aws_iam_policy.ecr_push_policy[each.value].arn
# }

resource "aws_iam_access_key" "ecr_user_access_key" {
  for_each = toset(var.ecr_name)
  user = aws_iam_user.ecr_user[each.value].name
}

output "ecr_user_access_key" {

  value = [for name, ecr in  aws_iam_access_key.ecr_user_access_key: {
    ecr_name = name
    id = ecr.id
    secret = ecr.secret
  }]
  sensitive = true
}

# output "ecr_push_role" {
#   value = [for i, ecr in aws_iam_role.ecr_push_role : {
#     name = i
#     arn = ecr.arn
#   }]
# }

output "ecr_name" {
  value = [for i, ecr in aws_ecr_repository.ecr : ecr.name]
}

output "ecr_arn" {
  value = [for i, ecr in aws_ecr_repository.ecr : ecr.arn]
}

