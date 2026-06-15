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