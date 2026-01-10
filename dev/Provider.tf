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
  access_key = "AKIAV336K2Z24BZSKMIS"
  secret_key = "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"

}
