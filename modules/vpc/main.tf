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
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.backbone.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {

    Name        = "${var.env_name}-public-subnet"
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.backbone.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false

  tags = {

    Name        = "${var.env_name}-private-subnet"
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

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

  for_each  = aws_subnet.public
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat" {


  domain = "vpc"

  tags = {

    Name = "${var.env_name}-nat-eip"
  }

}

resource "aws_nat_gateway" "main" {

  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id


  tags = {


    Name = "${var.env_name}-nat-gw"



  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "private" {

  vpc_id = aws_vpc.backbone.id

  route {

    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.env_name}-private-rt"
  }


}

resource "aws_route_table_association" "private" {

  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
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
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.public_sg.id]
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

resource "aws_instance" "backend_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id

  vpc_security_group_ids = [aws_security_group.private_sg.id]

  tags = {
    Name        = "${var.env_name}-backend-server"
    Environment = var.env_name
  }
}

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
  subnet_id     = aws_subnet.public.id

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

resource "aws_subnet" "public" {
  for_each          = toset(local.az_list)
  vpc_id            = aws_vpc.backbone.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(local.az_list, each.value))
  map_public_ip_on_launch = true

  tags = { Name = "${var.env_name}-public-subnet-${each.value}" }


}


resource "aws_subnet" "private" {
  for_each          = toset(local.az_list)
  vpc_id            = aws_vpc.backbone.id
  availability_zone = each.value
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, index(local.az_list, each.value))
  map_public_ip_on_launch = true

  tags = { Name = "${var.env_name}-private-subnet-${each.value}" }
}

