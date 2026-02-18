# resource "aws_iam_role" "this" {
#   name        = "EKS_TEST"
#   description = "Este rol es para eks"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })

# }

# resource "aws_iam_policy" "eks_to_s3" {
#   name        = "EKS_TO_S3"
#   description = "Eks policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Sid    = "PermitirAlBucketS3"
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject"
#         ]
#         Resource = ["*"]
#       },
#       {
#         Sid    = "AllowCloudWatchLogs"
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = ["*"]
#       }
#     ]
#   })
# }


# resource "aws_iam_role_policy_attachment" "this" {
#   role       = aws_iam_role.this.name
#   policy_arn = aws_iam_policy.eks_to_s3.arn
# }


# locals{
#   eks_managed_policies = [
#     "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
#     "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   ]
# }

# resource "aws_iam_role_policy_attachment" "managed" {
#   for_each = toset(local.eks_managed_policies)

#   role       = aws_iam_role.this.name
#   policy_arn = each.value
# }
