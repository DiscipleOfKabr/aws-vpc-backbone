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
    name = aws_iam_instance_profile.backend_profile.name
  }
  network_interfaces {
    security_groups = [aws_security_group.private_sg.id]
    associate_public_ip_address = false
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env_name}-backend-asg"
    }
  }

}
resource "aws_autoscaling_group" "backend_asg" {

  vpc_zone_identifier = [
    for key, config in var.subnet_configs :
    aws_subnet.main[key].id if config.type == "private"
  ]
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
    target_value = 61.0 # minimum cpu limit for correct scaling
  }
}