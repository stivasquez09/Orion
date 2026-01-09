locals {
  name_sg = "bc-norte-sg"
  vpc_id =  aws_vpc.main1.id
  description = "sg que va a BC por norte"

  sg_ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH desde mi IP"
    }

    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP public"
    }

    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS public"
    }

    allow_self = {
      from_port  = 0
      to_port    = 0
      protocol   = "-1"
      self       = true
      description = "comunicacion interna del SG"
    }
  }
}

