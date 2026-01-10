locals {
  vpc_id = aws_vpc.main1.id

  security_groups = {
    # ==================== WEB SERVER SG ====================
    web_server = {
      vpc_id      = local.vpc_id
      name        = "prod-web-server-sg"
      description = "Security group for web servers"

      ingress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS from Internet"
        },
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP from Internet"
        },
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
          description = "SSH from VPC"
        }
      ]

      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
          description = "All outbound traffic"
        }
      ]

      tags = {
        Name        = "prod-web-server-sg"
        Environment = "production"
      }
    }

    # ==================== APPLICATION SG ====================
    application = {
      vpc_id      = local.vpc_id
      name        = "prod-application-sg"
      description = "Security group for application tier"

      ingress_rules = [
        {
          from_port   = 8080
          to_port     = 8080
          protocol    = "tcp"
          self        = true
          description = "Inter-app communication"
        }
      ]

      egress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS to Internet"
        }
      ]

      tags = {
        Name        = "prod-application-sg"
        Environment = "production"
      }
    }

    # ==================== DATABASE SG ====================
    database = {
      vpc_id      = local.vpc_id
      name        = "prod-database-sg"
      description = "Security group for RDS PostgreSQL"

      ingress_rules = [
        {
          from_port   = 5432
          to_port     = 5432
          protocol    = "tcp"
          self        = true
          description = "PostgreSQL replication"
        }
      ]

      egress_rules = []

      tags = {
        Name        = "prod-database-sg"
        Environment = "production"
      }
    }

    # ==================== ALB SG ====================
    alb = {
      vpc_id      = local.vpc_id
      name        = "prod-alb-sg"
      description = "Security group for Application Load Balancer"

      ingress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS from Internet"
        },
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTP from Internet"
        }
      ]

      egress_rules = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
          description = "HTTPS outbound"
        }
      ]

      tags = {
        Name        = "prod-alb-sg"
        Environment = "production" # ✅ Agregado
      }
    } # ✅ Llave correctamente cerrada

    # ==================== BASTION HOST SG ====================
    bastion = {
      vpc_id      = local.vpc_id
      name        = "prod-bastion-sg"
      description = "Security group for bastion host"

      ingress_rules = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["203.0.113.0/24"]
          description = "SSH from corporate"
        }
      ]

      egress_rules = [
        {
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["10.0.0.0/16"]
          description = "SSH to VPC"
        }
      ]

      tags = {
        Name        = "prod-bastion-sg"
        Environment = "production"
      }
    }
  }
}
