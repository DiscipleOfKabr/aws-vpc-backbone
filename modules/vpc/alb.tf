resource "aws_lb" "web_lb" {
  name               = "dev-app-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for s in aws_subnet.main : s.id if s.map_public_ip_on_launch == true]

}

resource "aws_lb_target_group" "backend" {
  name     = "dev-backend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.backbone.id
}