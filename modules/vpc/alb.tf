resource "aws_lb" "web_lb" {
  name               = "dev-app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for s in aws_subnet.main : s.id if s.map_public_ip_on_launch == true]

}

#resource "aws_lb_target_group" "backend" {
#  name     = "dev-backend-tg"
#  port     = 80
#  protocol = "HTTP"
#  vpc_id   = aws_vpc.backbone.id
#}
resource "aws_lb" "backend_alb" {

  name               = "${var.env_name}-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [

    for key, subnet in aws_subnet.main : subnet.id
    if var.subnet_configs[key].type == "public"
  ]
}

resource "aws_lb_target_group" "backend_tg" {

  name     = "${var.env_name}-backend-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.backbone.id

  health_check {
    path = "/"

  }

}

# - - - Listener - - - 

resource "aws_lb_listener" "front_end" {

  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {

    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}


