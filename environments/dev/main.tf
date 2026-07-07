terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket       = "dev-tfstate-storage-9mcd4v-safe"
    key          = "dev/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }


  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

}





provider "aws" {

  region = var.aws_region

}

module "dev_network" {
  source   = "../../modules/vpc"
  vpc_cidr = "10.10.0.0/16"
  env_name = "dev"


}

output "dev_vpc_id" {

  value       = module.dev_network.vpc_id
  description = "The ID of the deployed dev vpc"
}


module "security" {
  source     = "../../modules/security"
  vpc_id     = module.dev_network.vpc_id
  env_name   = var.env_name
  app_port   = var.app_port
  https_port = var.https_port
}

module "compute" {
  source                    = "../../modules/compute"
  subnet_ids        = module.dev_network.public_subnet_ids
  alb_sg_id= module.security.alb_sg_id
  vpc_id = module.dev_network.vpc_id
  private_subnet_ids = module.dev_network.private_subnet_ids
  private_security_group_id = module.security.private_security_group_id
  backend_profile_name = module.security.backend_profile_name
  env_name = var.env_name
  app_port = var.app_port
}