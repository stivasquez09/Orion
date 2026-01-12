resource "aws_vpc" "main1" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "VPC1"
  }
}
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main1.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet1_public"
  }
}
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main1.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet2_private"
  }
}
