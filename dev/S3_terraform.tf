module "s3_bucket" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git"
  bucket = "${var.environment}-${data.aws_caller_identity.current.account_id}-InfraCloud-s3-bucket"
  create_bucket = true
  
  versioning = {
    enabled = true
  }

  lifecycle_rule = [
    {
      id      = "EliminarVersionesAntiguas"
      enabled = true

      noncurrent_version_expiration = {
        days = 3
      }
    }
  ]
}