resource "aws_vpc" "backbone" {

  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true


  tags = {

    Name        = "${var.env_name}-vpc-backbone"
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}
#resource "aws_subnet" "public" {
#  vpc_id                  = aws_vpc.backbone.id
#  cidr_block              = var.public_subnet_cidr
#  map_public_ip_on_launch = true
#
#  tags = {
#
#    Name        = "${var.env_name}-public-subnet"
#    Environment = var.env_name
#    ManagedBy   = "Terraform"
#  }
# old version of subnets,before dynamic implementation
#resource "aws_subnet" "private" {
#  vpc_id                  = aws_vpc.backbone.id
#  cidr_block              = var.private_subnet_cidr
#  map_public_ip_on_launch = false
#
#  tags = {
#
#    Name        = "${var.env_name}-private-subnet"
#    Environment = var.env_name
#    ManagedBy   = "Terraform"
#  }
#}

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.backbone.id

  tags = {

    Name        = "${var.env_name}-igw"
    Environment = var.env_name
  }
}



resource "aws_route_table" "public" {
  vpc_id = aws_vpc.backbone.id

  route {

    cidr_block = "0.0.0.0/0" #"represents the internet "
    gateway_id = aws_internet_gateway.gw.id

  }


  tags = {
    Name        = "${var.env_name}-public-rt"
    Environment = var.env_name
  }
}




resource "aws_route_table_association" "public" {

  for_each       = { for k, v in var.subnet_configs : k => v if v.type == "public" }
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.public.id
}


#resource "aws_eip" "nat" {
#
#
#  domain = "vpc"
#
#  tags = {
#
#    Name = "${var.env_name}-nat-eip"
#  }
#
#}

#resource "aws_nat_gateway" "main" {
#
#  subnet_id     = aws_subnet.public[local.az_list[0]].id
#  allocation_id = aws_eip.nat.id
#  depends_on    = [aws_internet_gateway.gw]
#
#
#  tags = {
#
#    Name = "${var.env_name}-nat-gw"
#
#  }
#
#
#
#}

resource "aws_route_table" "private" {

  for_each = { for k, v in var.subnet_configs : k => v if v.type == "private" }
  vpc_id   = aws_vpc.backbone.id

  route {
    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.main[replace(each.key, "private", "public")].id
  }

  tags = { Name = "${var.env_name}-private-rt-${each.key}"
  }

}

resource "aws_route_table_association" "private" {
  for_each       = { for k, v in var.subnet_configs : k => v if v.type == "private" }
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}



resource "aws_security_group" "public_sg" {
  name        = "${var.env_name}-public-sg"
  description = "Allow inbound web traffic"
  vpc_id      = aws_vpc.backbone.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_name}-public-sg"
  }
}

resource "aws_security_group" "private_sg" {
  name        = "${var.env_name}-private-sg"
  description = "Allow inbound traffic only from public sec. group"
  vpc_id      = aws_vpc.backbone.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_name}-private-sg"
  }
}

#old backend server block before asg implementation
#resource "aws_instance" "backend_server" {
#  ami           = data.aws_ami.amazon_linux_2023.id
#  instance_type = "t2.micro"
#  subnet_id     = aws_subnet.main["public_1a"].id
#
#  vpc_security_group_ids = [aws_security_group.private_sg.id]
#
#  tags = {
#    Name        = "${var.env_name}-backend-server"
#    Environment = var.env_name
#  }
#}

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

resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main["public_1a"].id

  # Attach our public web firewall
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  tags = {
    Name        = "${var.env_name}-web-server"
    Environment = var.env_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_list = slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_subnet" "main" {
  for_each                = var.subnet_configs
  vpc_id                  = aws_vpc.backbone.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = (each.value.type == "public")

  tags = { Name = "${var.env_name}-${each.key}" }


}






#old blocks
#resource "aws_subnet" "public" {
#  for_each                = toset(local.az_list)
#  vpc_id                  = aws_vpc.backbone.id
#  availability_zone       = each.value
#  cidr_block              = cidrsubnet(var.vpc_cidr, 8, index(local.az_list, each.value))
#  map_public_ip_on_launch = true
#
#  tags = { Name = "${var.env_name}-public-subnet-${each.value}" }
#
#
#}


#resource "aws_subnet" "private" {
#  for_each                = toset(local.az_list)
#  vpc_id                  = aws_vpc.backbone.id
#  availability_zone       = each.value
#  cidr_block              = cidrsubnet(var.vpc_cidr, 8, index(local.az_list, each.value)+10)
#  map_public_ip_on_launch = false
#
#  tags = { Name = "${var.env_name}-private-subnet-${each.value}" }
#}

resource "aws_eip" "nat" {
  for_each = { for k, v in var.subnet_configs : k => v if v.nat_gw }
  domain   = "vpc"
}

resource "aws_nat_gateway" "main" {
  for_each      = { for k, v in var.subnet_configs : k => v if v.nat_gw }
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.main[each.key].id
  depends_on    = [aws_internet_gateway.gw]
}

#Implementation of Auto Scaling group to decrease throttling in case of use-demand surge
resource "aws_launch_template" "backend" {
  name_prefix   = "${var.env_name}-backend-template-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"


  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tag_specifications {

    resource_type = "instance"
    tags = {
      Name = "${var.env_name}-backend-asg"
    }
  }
}

#old asg implementation

#resource "aws_autoscaling_group" "backend_asg" {
#  vpc_zone_identifier = [for s in aws_subnet.main :s.id if s.tags["Name"] == "${var.env_name}-private_1a" || s.tags["Name"] == "${var.env_name}private_1b"]
#
# desire_capacity = 2
# max_size  =4
#
# launch_template {
#
#  id    = aws_launch_template.backend.id
#  version = "$Latest"
# }
#
#}


resource "aws_autoscaling_group" "backend_asg" {

  vpc_zone_identifier = [
    for key, config in var.subnet_configs :
    aws_subnet.main[key].id if config.type == "private"
  ]
  target_group_arns = [aws_lb_target_group.backend_tg.arn]
  desired_capacity = 2
  max_size         = 4
  min_size         = 1
  health_check_type     = "ELB"
  health_check_grace_period = 300
  launch_template {

    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  lifecycle {
    create_before_destroy = true
  }


  tag {

    key   = "Name"
    value = "${var.env_name}-backend-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "backend_cpu_policy" {
 name   = "${var.env_name}-cpu-scaling"
 autoscaling_group_name = aws_autoscaling_group.backend_asg.name
 policy_type      = "TargetTrackingScaling"

 target_tracking_configuration{
  predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
   }
  target_value = 61.0 # minimum cpu limit for correct scaling
  }
 }




resource "aws_security_group" "alb_sg" {
  name      = "${var.env_name}-alb-sg"
  description = "ALB security group"
  vpc_id    = aws_vpc.backbone.id




  ingress {

    from_port   = 80
    to_port     = 80
    protocol    ="tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port =0
    to_port = 0
    protocol ="-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
}

resource "aws_lb" "backend_alb" {

    name     = "${var.env_name}-backend-alb"
    internal      = false
    load_balancer_type = "application"
    security_groups  = [aws_security_group.alb_sg.id] 

  subnets = [

    for key, subnet in aws_subnet.main : subnet.id
    if var.subnet_configs[key].type == "public"
  ]
}


resource "aws_lb_target_group" "backend_tg" {

 name  = "${var.env_name}-backend-tg"
 port  = 80
 protocol = "HTTP"
 vpc_id  = aws_vpc.backbone.id

 health_check {
  path = "/"

 }

}


# - - - Listener - - - 

resource "aws_lb_listener" "front_end"{

  load_balancer_arn = aws_lb.backend_alb.arn 
  port    = "80"
  protocol    = "HTTP"

  default_action {

    type  = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

