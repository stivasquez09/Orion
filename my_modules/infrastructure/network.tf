#vpc creation
resource "aws_vpc" "vpc_eks" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.environment}_VPC_EKS"
    Location = "US"
  }

      ## Prevent to destroy
lifecycle {
    prevent_destroy = false
  }
}


