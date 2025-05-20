variable "vpc_cidr" {
    default = "192.168.0.0/16"
  
}

variable "environment" {
  description = "Environment name, example: DEV or PROD"
  default = "DEV"
  type = string
}