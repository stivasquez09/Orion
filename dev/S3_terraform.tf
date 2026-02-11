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
  base_path = "env=${var.environment}/app=${var.application}"
  folders = [
    "${local.base_path}/",
    "${local.base_path}/year=${formatdate("YYYY", timestamp())}/",
    "${local.base_path}/year=${formatdate("YYYY", timestamp())}/month=${formatdate("MM", timestamp())}/"
  ]
}

resource "aws_s3_object" "folders" {
  for_each = toset(local.folders)

  bucket  = module.s3_bucket.s3_bucket_id
  key     = each.value
  content = ""
}
