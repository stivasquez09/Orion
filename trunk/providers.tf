provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      project      = var.project_name
      CostCenter   = "10.20.30"
      Environment  = var.environment
      Team_by = "InfraCloud"

    }
  }

}
