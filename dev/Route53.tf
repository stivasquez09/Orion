module "route53" {
  source      = "git::https://github.com/stivasquez09/Terraform_Modules_AWS.git//Route53?ref=v1.0.0"
  domain_name = "internal.example.local"
  zone_type   = "private"
  #  depends_on  = [aws_vpc.main1]
  vpc_ids    = [aws_vpc.main1.id]
  depends_on = [aws_lb.load_balancer_web] # ✅ Espera a que se cree el ALB

  tags = {
    Project = "platform"
    Env     = "dev"
  }

  records = [
    # -----------------------------
    # A record normal
    # -----------------------------
    {
      name    = "app.internal.example.local"
      type    = "A"
      ttl     = 300
      records = ["10.10.1.25"]
    },

    # -----------------------------
    # Alias (por ejemplo hacia ALB, NLB o CloudFront)
    # -----------------------------
    {
      name = "service.internal.example.local"
      type = "A"
      alias = {
        name                   = aws_lb.load_balancer_web.dns_name
        zone_id                = aws_lb.load_balancer_web.zone_id
        evaluate_target_health = true
      }
    }

    # # -----------------------------
    # # CNAME
    # # -----------------------------
    # {
    #   name    = "db.internal.example.local"
    #   type    = "CNAME"
    #   ttl     = 300
    #   records = ["database.internal.example.local"]
    # },

    # # -----------------------------
    # # TXT (útil para validaciones internas)
    # # -----------------------------
    # {
    #   name    = "_verify.internal.example.local"
    #   type    = "TXT"
    #   ttl     = 300
    #   records = ["\"internal-validation\""]
    # }
  ]
}
