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
  vpc_id      = aws_vpc.backbone.id
  cidr_block    = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {

    Name    = "${var.env_name}-public-subnet"
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}
resource "aws_subnet" "private" {
  vpc_id    = aws_vpc.backbone.id
  cidr_block  = var.private_subnet_cidr
  map_public_ip_on_launch = false

  tags = {

    Name   = "${var.env_name}-private-subnet"
    Environment =var.env_name
    ManagedBy = "Terraform"
  }
}

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.backbone.id 

  tags = {

    Name      = "${var.env_name}-igw"
    Environment = var.env_name
  }
}



resource "aws_route_table" "public"{
  vpc_id = aws_vpc.backbone.id

  route {

    cidr_block = "0.0.0.0/0" #"represents the internet "
    gateway_id = aws_internet_gateway.gw.id

  }


  tags = {
    Name    = "${var.env_name}-public-rt"
    Environment = var.env_name
  }
}




resource "aws_route_table_association" "public" {
  subnet_id   = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}


resource "aws_eip" "nat"{


domain ="vpc"

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

    cidr_block    = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name ="${var.env_name}-private-rt"
  }


}

resource "aws_route_table_association" "private" {

  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}