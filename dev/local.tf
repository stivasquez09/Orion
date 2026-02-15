# locals {
#   vpc_id = aws_vpc.main1.id

#   security_groups = {
#     # ==================== WEB SERVER SG ====================
#     web_server = {
#       vpc_id      = local.vpc_id
#       name        = "prod-web-server-sg"
#       description = "Security group for web servers"

#       ingress_rules = [
#         {
#           from_port   = 443
#           to_port     = 443
#           protocol    = "tcp"
#           cidr_blocks = ["0.0.0.0/0"]
#           description = "HTTPS from Internet"
#         },
#         {
#           from_port   = 80
#           to_port     = 80
#           protocol    = "tcp"
#           cidr_blocks = ["0.0.0.0/0"]
#           description = "HTTP from Internet"
#         },
#         {
#           from_port   = 22
#           to_port     = 22
#           protocol    = "tcp"
#           cidr_blocks = ["10.0.0.0/16"]
#           description = "SSH from VPC"
#         }
#       ]

#       egress_rules = [
#         {
#           from_port   = 0
#           to_port     = 0
#           protocol    = "-1"
#           cidr_blocks = ["0.0.0.0/0"]
#           description = "All outbound traffic"
#         }
#       ]

#       tags = {
#         Name        = "prod-web-server-sg"
#         Environment = "production"
#       }
#     }

#     # ==================== APPLICATION SG ====================
#     application = {
#       vpc_id      = local.vpc_id
#       name        = "prod-application-sg"
#       description = "Security group for application tier"

#       ingress_rules = [
#         {
#           from_port   = 8080
#           to_port     = 8080
#           protocol    = "tcp"
#           self        = true
#           description = "Inter-app communication"
#         }
#       ]

#       egress_rules = [
#         {
#           from_port   = 443
#           to_port     = 443
#           protocol    = "tcp"
#           cidr_blocks = ["0.0.0.0/0"]
#           description = "HTTPS to Internet"
#         }
#       ]

#       tags = {
#         Name        = "prod-application-sg"
#         Environment = "production"
#       }
#     }

#     # ==================== DATABASE SG ====================
#     database = {
#       vpc_id      = local.vpc_id
#       name        = "prod-database-sg"
#       description = "Security group for RDS PostgreSQL"

#       ingress_rules = [
#         {
#           from_port   = 5432
#           to_port     = 5432
#           protocol    = "tcp"
#           self        = true
#           description = "PostgreSQL replication"
#         }
#       ]

#       egress_rules = []

#       tags = {
#         Name        = "prod-database-sg"
#         Environment = "production"
#       }
#     }

#     # ==================== ALB SG ====================
#     alb = {
#       vpc_id      = local.vpc_id
#       name        = "prod-alb-sg"
#       description = "Security group for Application Load Balancer"

#       ingress_rules = [
#         {
#           from_port   = 443
#           to_port     = 443
#           protocol    = "tcp"
#           cidr_blocks = ["0.0.0.0/0"]
#           description = "HTTPS from Internet"
#         },
#         {
#           from_port   = 80
#           to_port     = 80
#           protocol    = "tcp"
#           cidr_blocks = ["0.0.0.0/0"]
#           description = "HTTP from Internet"
#         }
#       ]

#       egress_rules = [
#         {
#           from_port   = 443
#           to_port     = 443
#           protocol    = "tcp"
#           cidr_blocks = ["0.0.0.0/0"]
#           description = "HTTPS outbound"
#         }
#       ]

#       tags = {
#         Name        = "prod-alb-sg"
#         Environment = "production" # ✅ Agregado
#       }
#     } # ✅ Llave correctamente cerrada

#     # ==================== BASTION HOST SG ====================
#     bastion = {
#       vpc_id      = local.vpc_id
#       name        = "prod-bastion-sg"
#       description = "Security group for bastion host"

#       ingress_rules = [
#         {
#           from_port   = 22
#           to_port     = 22
#           protocol    = "tcp"
#           cidr_blocks = ["203.0.113.0/24"]
#           description = "SSH from corporate"
#         }
#       ]

#       egress_rules = [
#         {
#           from_port   = 22
#           to_port     = 22
#           protocol    = "tcp"
#           cidr_blocks = ["10.0.0.0/16"]
#           description = "SSH to VPC"
#         }
#       ]

#       tags = {
#         Name        = "prod-bastion-sg"
#         Environment = "production"
#       }
#     }
#   }
# }
# # ============================================
# # Route53 Hosted Zones - Multi-domain
# # ============================================
# locals {
#   # VPC IDs para zonas privadas
#   vpc_main_id = aws_vpc.main1.id
#   #vpc_dev_id  = "vpc-0a1b2c3d" # Si tienes otra VPC

#   hosted_zones = {

#     # ==================== ZONA PRIVADA: INTERNAL ====================
#     internal = {
#       domain_name = "new.example.local"
#       zone_type   = "private"
#       comment     = "Internal private DNS zone"
#       vpc_ids     = [local.vpc_main_id]

#       tags = {
#         Project     = "platform"
#         Environment = "production"
#         Type        = "private"
#       }

#       records = [
#         # A record
#         {
#           name    = "app.new.example.local"
#           type    = "A"
#           ttl     = 300
#           records = ["10.10.1.25"]
#         },
#         # Database CNAME
#         {
#           name    = "db.new.example.local"
#           type    = "CNAME"
#           ttl     = 300
#           records = ["rds-postgres.new.example.local"]
#         },
#         # Redis
#         {
#           name    = "redis.new.example.local"
#           type    = "A"
#           ttl     = 300
#           records = ["10.10.1.50"]
#         }
#       ]
#     }

#     # ==================== ZONA PRIVADA: SERVICES ====================
#     services = {
#       domain_name = "services.internal.local"
#       zone_type   = "private"
#       comment     = "Microservices internal DNS"
#       vpc_ids     = [local.vpc_main_id]

#       tags = {
#         Project     = "microservices"
#         Environment = "production"
#         Type        = "private"
#       }

#       records = [
#         # API Gateway
#         {
#           name    = "api.services.internal.local"
#           type    = "A"
#           ttl     = 300
#           records = ["10.10.2.10"]
#         },
#         # Auth service
#         {
#           name    = "auth.services.internal.local"
#           type    = "A"
#           ttl     = 300
#           records = ["10.10.2.20"]
#         },
#         # User service
#         {
#           name    = "users.services.internal.local"
#           type    = "A"
#           ttl     = 300
#           records = ["10.10.2.30"]
#         }
#       ]
#     }

#     # # ==================== ZONA PRIVADA: DEV ====================
#     # dev_internal = {
#     #   domain_name = "dev.internal.local"
#     #   zone_type   = "private"
#     #   comment     = "Development environment DNS"
#     #   vpc_ids     = [local.vpc_dev_id]

#     #   tags = {
#     #     Project     = "platform"
#     #     Environment = "development"
#     #     Type        = "private"
#     #   }

#     #   records = [
#     #     {
#     #       name    = "app-dev.dev.internal.local"
#     #       type    = "A"
#     #       ttl     = 300
#     #       records = ["10.20.1.10"]
#     #     },
#     #     {
#     #       name    = "db-dev.dev.internal.local"
#     #       type    = "A"
#     #       ttl     = 300
#     #       records = ["10.20.1.20"]
#     #     }
#     #   ]
#     # }

#     #   # ==================== ZONA PÚBLICA: EXAMPLE.COM ====================
#     #   public_main = {
#     #     domain_name = "example.com"
#     #     zone_type   = "public"
#     #     comment     = "Main public domain"

#     #     tags = {
#     #       Project     = "website"
#     #       Environment = "production"
#     #       Type        = "public"
#     #     }

#     #     records = [
#     #       # Root domain - A record
#     #       {
#     #         name    = "example.com"
#     #         type    = "A"
#     #         ttl     = 300
#     #         records = ["203.0.113.10"]
#     #       },
#     #       # WWW - CNAME
#     #       {
#     #         name    = "www.example.com"
#     #         type    = "CNAME"
#     #         ttl     = 300
#     #         records = ["example.com"]
#     #       },
#     #       # API subdomain
#     #       {
#     #         name    = "api.example.com"
#     #         type    = "A"
#     #         ttl     = 300
#     #         records = ["203.0.113.20"]
#     #       },
#     #       # Mail records
#     #       {
#     #         name    = "example.com"
#     #         type    = "MX"
#     #         ttl     = 300
#     #         records = ["10 mail.example.com"]
#     #       },
#     #       # SPF
#     #       {
#     #         name    = "example.com"
#     #         type    = "TXT"
#     #         ttl     = 300
#     #         records = ["\"v=spf1 include:_spf.google.com ~all\""]
#     #       }
#     #     ]
#     #   }

#     #   # ==================== ZONA PÚBLICA: APP.COM (con ALB Alias) ====================
#     #   public_app = {
#     #     domain_name = "app-example.com"
#     #     zone_type   = "public"
#     #     comment     = "Application public domain with ALB"

#     #     tags = {
#     #       Project     = "app"
#     #       Environment = "production"
#     #       Type        = "public"
#     #     }

#     #     records = [
#     #       # Root con Alias a ALB
#     #       {
#     #         name = "app-example.com"
#     #         type = "A"
#     #         alias = {
#     #           name                   = "my-alb-123456.us-east-1.elb.amazonaws.com"
#     #           zone_id                = "Z35SXDOTRQ7X7K"  # ALB zone ID
#     #           evaluate_target_health = true
#     #         }
#     #       },
#     #       # WWW con Alias a ALB
#     #       {
#     #         name = "www.app-example.com"
#     #         type = "A"
#     #         alias = {
#     #           name                   = "my-alb-123456.us-east-1.elb.amazonaws.com"
#     #           zone_id                = "Z35SXDOTRQ7X7K"
#     #           evaluate_target_health = true
#     #         }
#     #       },
#     #       # API subdomain
#     #       {
#     #         name    = "api.app-example.com"
#     #         type    = "A"
#     #         ttl     = 300
#     #         records = ["203.0.113.30"]
#     #       }
#     #     ]
#     #   }

#     #   # ==================== ZONA PÚBLICA: SUBDOMAIN ====================
#     #   public_subdomain = {
#     #     domain_name = "blog.example.com"
#     #     zone_type   = "public"
#     #     comment     = "Blog subdomain"

#     #     tags = {
#     #       Project     = "blog"
#     #       Environment = "production"
#     #       Type        = "public"
#     #     }

#     #     records = [
#     #       {
#     #         name    = "blog.example.com"
#     #         type    = "A"
#     #         ttl     = 300
#     #         records = ["198.51.100.10"]
#     #       },
#     #       {
#     #         name    = "www.blog.example.com"
#     #         type    = "CNAME"
#     #         ttl     = 300
#     #         records = ["blog.example.com"]
#     #       }
#     #     ]
#     #   }

#   }
# }


