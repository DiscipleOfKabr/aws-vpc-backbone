resource "aws_lb" "backend_alb" {

  name               = "${var.env_name}-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]

  subnets = var.subnet_ids
}

resource "aws_lb_target_group" "backend_tg" {

  name     = "${var.env_name}-backend-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

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


