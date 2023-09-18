resource "aws_iam_policy" "ecs_update_service_policy" {
  name        = "${var.name}-ECSUpdateServicePolicy"
  description = "Policy to allow updating ECS service"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ECSTaskUpdate",
      "Effect": "Allow",
      "Action": "ecs:UpdateService",
      "Resource": "arn:aws:ecs:*:*:service/${var.name}-cluster/${var.name}-service"
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_update_service_role" {
  name               = "${var.name}-ECSUpdateServiceRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
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
          }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_update_service_attachment" {
  role       = aws_iam_role.ecs_update_service_role.name
  policy_arn = aws_iam_policy.ecs_update_service_policy.arn
}

output "iam_role_for_cicd" {
  value = aws_iam_role.ecs_update_service_role.arn
}
