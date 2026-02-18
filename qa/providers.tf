provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      project      = "Orion"
      CostCenter   = "10.20.30"
      Environment  = "QA"
      terraform_by = "InfraCloud"

    }
  }

}
