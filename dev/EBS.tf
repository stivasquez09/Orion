resource "aws_ebs_volume" "ejemplo_ebs" {
  availability_zone = "us-east-1a" # Reemplaza con tu zona de disponibilidad
  size              = 10           # Tamaño en GB
  type              = "gp3"        # Tipo de volumen (gp3, gp2, io1, etc.)

  tags = {
    Name = "Volumen-EBS-Terraform"
  }
}

resource "aws_ebs_volume" "ejemplo_ebs1" {
  availability_zone = "us-east-1a" # Reemplaza con tu zona de disponibilidad
  size              = 20           # Tamaño en GB
  type              = "gp3"        # Tipo de volumen (gp3, gp2, io1, etc.)

  tags = {
    Name = "Volumen-EBS-Terraform1"
  }
}