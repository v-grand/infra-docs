# AWS Development Environment Example

This example demonstrates how to set up a complete development environment on AWS using `infra-core` modules.

It includes:
- A VPC with subnets
- An EC2 instance (VM)
- An RDS MySQL database
- Tailscale integration for secure access

## Configuration (`main.tf`)

```hcl
# main.tf for aws-dev example

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../modules/vpc"

  provider          = "aws"
  cidr_block        = "10.0.0.0/16"
  subnet_cidr_block = "10.0.1.0/24"
  tags = {
    Name = "aws-dev-vpc"
  }
}

module "vm" {
  source = "../../modules/vm"

  provider      = "aws"
  ami           = "ami-0c55b159cbfafe1f0" # us-east-1
  instance_type = "t2.micro"
  tags = {
    Name = "aws-dev-vm"
  }
}

module "db" {
  source = "../../modules/db"

  provider          = "aws"
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t2.micro"
  db_name           = "awsdevdb"
  username          = "user"
  password          = "password" # Replace with a secure password
  tags = {
    Name = "aws-dev-db"
  }
}

module "tailscale" {
  source = "../../modules/tailscale"

  instance_id      = module.vm.instance_id
  auth_key         = "your-tailscale-auth-key" # Replace with your auth key
  ssh_user         = "ec2-user"
  private_key_path = "~/.ssh/id_rsa" # Replace with your private key path
  host             = module.vm.public_ip
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vm_id" {
  value = module.vm.instance_id
}

output "db_id" {
  value = module.db.db_instance_id
}
```
