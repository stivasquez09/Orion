# variable "deploy_role_name" {
#   description = "Nombre del rol IAM usado por GitHub Actions para desplegar"
#   type        = string
# }

variable "environment" {
  default     = "DEV"
  description = "etiqueta para ambiente"

}

variable "application" {
  default       = "Orion"
  description = "Carpetas para bucket Orion"
}


#  aws secretsmanager delete-secret   --secret-id prod/redis-auth   --force-delete-without-recovery
#  aws secretsmanager delete-secret   --secret-id prod/api-key   --force-delete-without-recovery
# aws secretsmanager delete-secret   --secret-id prod/db-password   --force-delete-without-recovery