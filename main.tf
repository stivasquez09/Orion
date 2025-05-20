provider "aws" {
  region = "${var.my_region}"
  default_tags {
    tags = {
      project = "${var.environment}_EKS + PODS KUBERNETES"
    }
  }

}

module "dev_infrastructure" {
  
  source = "./my_modules/infrastructure"

}

  
# module "ec2" {
#   source = "./modules/vpc"
#   subnet_id = module.vpc.subnet_id

# } 