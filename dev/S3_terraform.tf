module "s3_bucket" {
  source        = "git::https://github.com/terraform-aws-modules/terraform-aws-s3-bucket.git"
  bucket        = "${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket"
  create_bucket = false

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

locals {
  folders = {
    incoming  = "${var.environment}/payments/incoming/"
    processed = "${var.environment}/payments/processed/"
    archive   = "${var.environment}/payments/archive/"
    nuevadata = "${var.environment}/payments/archive/nueva_data/"
    promesas  = "${var.environment}/payments/archive/promesas/"
  }
}


resource "aws_s3_object" "folders" {
  for_each = local.folders

  bucket  = "${var.environment}-${data.aws_caller_identity.current.account_id}-infracloud-s3-bucket"
  key     = each.value
  content = ""
}

