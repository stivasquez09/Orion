# # ============================================
# # WEB SERVER - Combinación de CIDR y SG
# # ============================================
# module "web_server_sg" {
#   source      = "git::https://github.com/stivasquez09/Terraform_Modules_AWS.git//SG?ref=master"
#   name        = "web-server-sg"
#   description = "Web server with mixed access"
#   vpc_id      = aws_vpc.main1.id
#   ingress_rules = [
#     # ❌ NO COMBINAR: cidr_blocks con source_security_group_id
#     # ✅ CORRECTO: Regla 1 - Solo CIDR
#     {
#       from_port   = 443
#       to_port     = 443
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "HTTPS from Internet"
#     },
#     # ✅ CORRECTO: Regla 2 - Solo Security Group
#     {
#       from_port   = 22
#       to_port     = 22
#       protocol    = "tcp"
#       self        = true
#       description = "SSH from bastion"
#     }
#   ]

#   egress_rules = [
#     {
#       from_port   = 0
#       to_port     = 0
#       protocol    = "-1"
#       cidr_blocks = ["0.0.0.0/0"]
#       description = "All outbound"
#     }
#   ]

#   tags = {
#     Name = "web-server-sg"
#   }
# }
