output "asg_name" {
  value = aws_autoscaling_group.backend_asg.name
}

output "alb_dns_name" {

  value = aws_lb.backend_alb.dns_name

}

