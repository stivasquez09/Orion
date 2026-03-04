data "aws_caller_identity" "current" {}

data "aws_iam_role" "deploy" {
  name = var.deploy_role_name
}
