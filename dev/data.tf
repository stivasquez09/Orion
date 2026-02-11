data "aws_caller_identity" "current" {}
variable "environment" {
  default     = "DEV"
  description = "etiqueta para ambiente"

}

variable "application" {
  default       = "Orion"
  description = "Carpetas para bucket Orion"
}
