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


