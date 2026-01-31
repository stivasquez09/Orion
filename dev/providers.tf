provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      project      = "Orion"
      CostCenter   = "10.20.30"
      Environment  = "DEV"
      terraform_by = "InfraCloud"

    }
  }

}
