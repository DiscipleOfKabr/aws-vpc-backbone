# Networking
output "vpc_id" { value = aws_vpc.backbone.id }

# Security
output "private_sg_id" { value = aws_security_group.private_sg.id }

# Compute
output "asg_name" { value = aws_autoscaling_group.backend_asg.name }

# Load Balancing
output "alb_dns_name" { value = aws_lb.backend_alb.dns_name }