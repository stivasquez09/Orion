terraform {
  backend "s3" {
    bucket = "dev-403455006325-infracloud-s3-bucket"            # Nombre del bucket donde se guardará el state
    key    = "dev/terraform.tfstate" # Ruta/nombre del archivo state dentro del bucket
    region = "us-east-1"                      # Región del bucket
    encrypt = true                           
  }
}