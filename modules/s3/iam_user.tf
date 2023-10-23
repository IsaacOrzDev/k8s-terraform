resource "aws_iam_user" "s3_user" {
  name = "${var.bucket_name}-s3-user"
}

resource "aws_iam_user_policy" "s3_user_policy" {
  name   = "${var.bucket_name}-s3-user-policy"
  user   = aws_iam_user.s3_user.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_access_key" "s3_user_access_key" {
  user = aws_iam_user.s3_user.name
}

output "s3_user_access_key" {
  value = aws_iam_access_key.s3_user_access_key.id
}

output "s3_user_secret_key" {
  value     = aws_iam_access_key.s3_user_access_key.secret
  sensitive = true
}
