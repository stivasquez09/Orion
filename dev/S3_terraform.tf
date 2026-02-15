# module "s3_bucket" {
#   source        = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git"
#   bucket        = "${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket"
#   create_bucket = false

#   versioning = {
#     enabled = true
#   }

#   lifecycle_rule = [
#     {
#       id      = "EliminarVersionesAntiguas"
#       enabled = true

#       noncurrent_version_expiration = {
#         days = 3
#       }
#     }
#   ]
# }

# # locals {
# #   folders = {
# #     incoming         = "${var.environment}/payments/incoming/"
# #     processed        = "${var.environment}/payments/processed/"
# #     archive          = "${var.environment}/payments/archive/"
# #     nuevadata        = "${var.environment}/payments/archive/nueva_data/"
# #     promesas         = "${var.environment}/payments/archive/promesas/"
# #     orders_incoming  = "${var.environment}/orders/incoming/"
# #     orders_processed = "${var.environment}/orders/processed/"
# #   }
# # }


# # resource "aws_s3_object" "folders" {
# #   for_each = local.folders

# #   bucket  = "${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket"
# #   key     = each.value
# #   content = ""
# # }

# locals {
#   folders = [
#     "${var.environment}/backups/",
#     "${var.environment}/backups/ec2/",
#     "${var.environment}/orders/",
#     "${var.environment}/orders/recaudos/"


#   ]
# }

# resource "aws_s3_object" "folders" {
#   for_each = { for key in local.folders : key => key }

#   bucket = "${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket"
#   key    = each.value
# }


# resource "aws_s3_bucket_policy" "this" {
#   bucket = "${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [

#       # 1️⃣ Forzar HTTPS
#       {
#         Sid       = "DenyInsecureTransport"
#         Effect    = "Deny"
#         Principal = "*"
#         Action    = "s3:*"
#         Resource = [
#           "arn:aws:s3:::${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket",
#           "arn:aws:s3:::${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:SecureTransport" = "false"
#           }
#         }
#       },

#       # 2️⃣ Permitir escribir solo en incoming
#       {
#         Sid    = "AllowWriteIncoming"
#         Effect = "Allow"
#         Principal = {
#           AWS = data.aws_iam_role.deploy.arn
#         }
#         Action = [
#           "s3:PutObject"
#         ]
#         Resource = "arn:aws:s3:::${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket/${var.environment}/orders/recaudos/*"
#       },
#       {
#         Sid       = "DenyWriteProcessed"
#         Effect    = "Deny"
#         Principal = "*"
#         Action    = "s3:PutObject"
#         Resource  = "arn:aws:s3:::${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket/${var.environment}/backups/ec2/*"
#       },

#       # 3️⃣ Permitir lectura en archive
#       {
#         Sid    = "AllowReadArchive"
#         Effect = "Allow"
#         Principal = {
#           AWS = data.aws_iam_role.deploy.arn
#         }
#         Action = [
#           "s3:GetObject"
#         ]
#         Resource = "arn:aws:s3:::${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket/${var.environment}/payments/archive/*"
#       },

#       # 4️⃣ Denegar borrado global
#       {
#         Sid       = "DenyDeletes"
#         Effect    = "Allow"
#         Principal = { AWS = data.aws_iam_role.deploy.arn }
#         Action = [
#           "s3:DeleteObject"
#         ]
#         Resource = "arn:aws:s3:::${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket/*"
#       }
#     ]
#   })
# }
