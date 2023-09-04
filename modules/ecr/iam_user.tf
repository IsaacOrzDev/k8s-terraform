# resource "aws_iam_user" "ecr_user" {
#   for_each = toset(var.ecr_name)
#   name     = "${each.value}-ecr-cicd-user"
# }

# resource "aws_iam_user_policy_attachment" "ecr_user_attachment" {
#   for_each   = toset(var.ecr_name)
#   user       = aws_iam_user.ecr_user[each.value].name
#   policy_arn = aws_iam_policy.ecr_push_policy[each.value].arn
# }

# resource "aws_iam_access_key" "ecr_user_access_key" {
#   for_each = toset(var.ecr_name)
#   user     = aws_iam_user.ecr_user[each.value].name
# }

# output "ecr_user_access_key" {

#   value = [for name, ecr in aws_iam_access_key.ecr_user_access_key : {
#     ecr_name = name
#     id       = ecr.id
#     secret   = ecr.secret
#   }]
#   sensitive = true
# }
