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

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.backbone.id

  tags = {

    Name        = "${var.env_name}-igw"
    Environment = var.env_name
  }
}
resource "aws_subnet" "main" {
  for_each                = var.subnet_configs
  vpc_id                  = aws_vpc.backbone.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = (each.value.type == "public")

  tags = { Name = "${var.env_name}-${each.key}" }


}

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
