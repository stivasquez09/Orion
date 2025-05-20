
variable "my_region" {
  description = "Aws region to use on deployments"
  default = "us-east-1"
  type = string
}

variable "my_profile" {
  description = "Aws profile used to get the credentials"
  default = "default"
  type = string
}

variable "environment" {
  description = "Environment name, example: DEV or PROD"
  default = "DEV"
  type = string
}
