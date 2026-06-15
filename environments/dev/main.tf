terraform {


    required_version = ">= 1.0"
    required_providers{
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    }
}

provider "aws" {

region = "eu-west-1"

}

module "dev_network" {
    source = "../../modules/vpc"
    vpc_cidr = "10.10.0.0/16"
    env_name = "dev"

public_subnet_cidr = "10.10.1.0/24"
private_subnet_cidr = "10.10.2.0/24"
}

output "dev_vpc_id"{

    value   = module.dev_network.vpc_id 
    description = "The ID of the deployed dev vpc"
}