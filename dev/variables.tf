variable "deploy_role_name" {
  description = "Nombre del rol IAM usado por GitHub Actions para desplegar"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue (dev, qa, prod, uat)"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
}

variable "application" {
  default       = "Orion"
  description = "Carpetas para bucket Orion"
}

# variable "secrets" {
#   description = "Mapa de secretos a crear"
#   type        = map(any)
# }

#  aws secretsmanager delete-secret   --secret-id prod/redis-auth   --force-delete-without-recovery
#  aws secretsmanager delete-secret   --secret-id prod/api-key   --force-delete-without-recovery
# aws secretsmanager delete-secret   --secret-id prod/db-password   --force-delete-without-recovery