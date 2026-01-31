# # ============================================
# # ALB (ejemplo)
# # ============================================
# resource "aws_lb" "load_balancer_web" {
#   name               = "webserver-alb"
#   load_balancer_type = "application"
#   internal           = true
#   subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

#   tags = {
#     Name = "webserver-ALB"
#   }
# }
