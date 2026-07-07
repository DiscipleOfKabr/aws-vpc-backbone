AWS VPC Backbone Infrastructure
This project provides a modular and secure foundation for deploying an AWS VPC architecture using Terraform. It is designed to be reusable and scalable, separating networking, security, and compute concerns into distinct modules.

Architecture Overview
The infrastructure follows a modular design pattern, where the networking layer provides the foundation for security groups and compute resources.

The dependency graph below illustrates the relationship between the resources and the data flow between modules:

Project Structure :

.
├── environments/dev/   # Environment-specific configuration and state
├── modules/            # Reusable infrastructure modules
│   ├── compute/        # ALB and Compute instance definitions
│   ├── security/       # Security group and IAM configuration
│   └── vpc/            # VPC, Subnet, and Routing logic
└── scripts/            # Helper scripts for setup and deployment


///////////////////


Prerequisites
Terraform (v1.0.0+)

AWS CLI configured with appropriate IAM credentials.


Deployment Steps
1) Initialize: Navigate to the environment directory and initialize Terraform.


_cd environments/dev
terraform init_

2) Plan: Review the infrastructure changes.
   _terraform plan -out=my_plan.tfplan_


3) Apply: Deploy the resources to AWS.

   _terraform apply "my_plan.tfplan"_

///////////////////////
Troubleshooting
If you encounter errors, please check the following:

403 Forbidden / Access Denied: Ensure your IAM user has the necessary permissions policy for the S3 state bucket and associated KMS keys (if encryption is enabled).

Could not connect to endpoint: Verify that your region setting in backend_infra.tf matches the region where your S3 bucket resides.

State Locked: If a previous apply failed, you may need to manually release the state lock in DynamoDB.

To tear down the infrastructure and avoid unnecessary AWS costs, run:

_terraform destroy_

/////////////////////


### Infrastructure Dependency Graph
![Dependency Graph](docs/assets/aws-vpc-backbone.drawio.svg)



