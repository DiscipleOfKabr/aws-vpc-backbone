data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-minimal-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}



#Implementation of Auto Scaling group to decrease throttling in case of use-demand surge

resource "aws_launch_template" "backend" {
  name_prefix   = "${var.env_name}-backend-template-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"


  iam_instance_profile {
    name = var.backend_profile_name
  }
  network_interfaces {
    security_groups             = [var.private_security_group_id]
    associate_public_ip_address = false
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env_name}-backend-asg"
    }
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Hello from the backend" > /var/www/html/index.html
  EOF
  )

}
resource "aws_autoscaling_group" "backend_asg" {

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns         = [aws_lb_target_group.backend_tg.arn]
  desired_capacity          = 2
  max_size                  = 4
  min_size                  = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {

    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  lifecycle {
    create_before_destroy = true
  }


  tag {

    key                 = "Name"
    value               = "${var.env_name}-backend-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "backend_cpu_policy" {
  name                   = "${var.env_name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.backend_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0 # minimum cpu limit for correct scaling
  }
}