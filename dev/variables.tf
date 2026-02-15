variable "deploy_role_name" {
  description = "Nombre del rol IAM usado por GitHub Actions para desplegar"
  type        = string
}

variable "environment" {
  default     = "DEV"
  description = "etiqueta para ambiente"

}

variable "application" {
  default       = "Orion"
  description = "Carpetas para bucket Orion"
}

variable "secrets" {
  description = "Mapa de secretos a crear"
  type        = map(any)
}

