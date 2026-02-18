# resource "aws_secretsmanager_secret" "this" {
#   for_each = var.secrets

#   name                    = each.key
#   description             = "Secret managed by Terraform"
#   recovery_window_in_days = 0


#   tags = {
#     Environment = "prod"
#     Project     = "ecommerce"
#     Owner       = "platform-team"
#     ManagedBy   = "Terraform"
#   }
# }
# resource "aws_secretsmanager_secret_version" "this" {
#   for_each = var.secrets

#   secret_id     = aws_secretsmanager_secret.this[each.key].id
#   secret_string = jsonencode(each.value)
# }

# resource "aws_secretsmanager_secret_policy" "this" {
#   for_each = var.secrets

#   secret_arn = aws_secretsmanager_secret.this[each.key].arn

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           AWS = "*"
#         }
#         Action = [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# output "secret_arns" {
#   value = {
#     for k, v in aws_secretsmanager_secret.this :
#     k => v.arn
#   }
# }
