# ============================================
# Route53 Hosted Zones - Multi-domain
# ============================================
module "route53_multi" {
  source = "git::https://github.com/stivasquez09/Terraform_Modules_AWS.git//Route53?ref=v1.0.0"
  
  for_each = local.hosted_zones

  domain_name   = each.value.domain_name
  zone_type     = each.value.zone_type
  comment       = lookup(each.value, "comment", "Managed by Terraform")
  force_destroy = lookup(each.value, "force_destroy", false)
  vpc_ids       = lookup(each.value, "vpc_ids", [])
  records       = lookup(each.value, "records", [])
  tags          = each.value.tags
  optional_tags = lookup(each.value, "optional_tags", {})
}