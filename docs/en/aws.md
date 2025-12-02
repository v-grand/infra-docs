# AWS Infrastructure

**infra-aws** manages AWS infrastructure deployment using Terraform modules from infra-core, providing standardized cloud resource provisioning.

## 🎯 Purpose

Deploy and manage AWS infrastructure:

- **EC2 Instances** - Virtual machine deployment
- **VPC Configuration** - Network infrastructure
- **RDS Databases** - Managed databases
- **EKS Clusters** - Kubernetes on AWS
- **S3 Storage** - Object storage
- **IAM Policies** - Access management

## 📁 Repository Structure

```
infra-aws/
├── bootstrap/              # Initial AWS setup
│   ├── iam/               # IAM roles and policies
│   ├── s3/                # S3 buckets for Terraform state
│   └── dynamodb/          # DynamoDB for state locking
├── infra/                 # Main infrastructure
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   ├── backend.tf
│   └── outputs.tf
├── ops/                   # Operational scripts
│   ├── ssh_config.example
│   └── scripts/
├── ide/                   # IDE configurations
└── README.md
```

## 🚀 Quick Start

### 1. Prerequisites

- [Terraform](https://terraform.io/downloads) >= 1.5.0
- AWS CLI configured with credentials
- Existing EC2 key pair (or create new one)

```bash
# Configure AWS CLI
aws configure

# Verify access
aws sts get-caller-identity
```

### 2. Bootstrap Infrastructure

```bash
# Clone repository
git clone https://github.com/v-grand/infra-aws.git
cd infra-aws

# Bootstrap (first time only)
cd bootstrap
terraform init
terraform apply

# This creates:
# - S3 bucket for Terraform state
# - DynamoDB table for state locking
# - Basic IAM roles
```

### 3. Deploy Main Infrastructure

```bash
cd ../infra

# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
nano terraform.tfvars
```

**terraform.tfvars example:**
```hcl
# AWS Configuration
aws_region = "us-east-1"
key_name   = "my-ec2-key"

# Network Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# SSH Access
allowed_ssh_cidr = "YOUR_IP/32"  # Get with: curl ifconfig.me

# Application
repo_url    = "https://github.com/your-org/your-app.git"
repo_branch = "main"

# Tags
tags = {
  Environment = "dev"
  Project     = "my-app"
  ManagedBy   = "terraform"
}
```

```bash
# Deploy
terraform init
terraform plan
terraform apply
```

## 🏗️ Architecture

### Basic Architecture

```
┌─────────────────────────────────────────────┐
│              AWS Region (us-east-1)         │
│  ┌────────────────────────────────────────┐ │
│  │           VPC (10.0.0.0/16)            │ │
│  │  ┌──────────────┬──────────────────┐  │ │
│  │  │   AZ-1a      │      AZ-1b       │  │ │
│  │  │              │                  │  │ │
│  │  │  Public      │    Public        │  │ │
│  │  │  Subnet      │    Subnet        │  │ │
│  │  │  10.0.1/24   │    10.0.2/24     │  │ │
│  │  │  ┌────────┐  │   ┌────────┐     │  │ │
│  │  │  │  EC2   │  │   │  EC2   │     │  │ │
│  │  │  │  ALB   │  │   │  ALB   │     │  │ │
│  │  │  └────────┘  │   └────────┘     │  │ │
│  │  │              │                  │  │ │
│  │  │  Private     │    Private       │  │ │
│  │  │  Subnet      │    Subnet        │  │ │
│  │  │  10.0.10/24  │    10.0.11/24    │  │ │
│  │  │  ┌────────┐  │   ┌────────┐     │  │ │
│  │  │  │  RDS   │  │   │  RDS   │     │  │ │
│  │  │  │(Primary)│  │   │(Standby)│    │  │ │
│  │  │  └────────┘  │   └────────┘     │  │ │
│  │  └──────────────┴──────────────────┘  │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## 📦 Modules Usage

### Deploy EC2 Instance

```hcl
module "web_server" {
  source = "github.com/v-grand/infra-core//modules/vm"
  
  cloud         = "aws"
  instance_name = "web-server"
  instance_type = "t3.medium"
  
  # Network
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [aws_security_group.web.id]
  
  # SSH
  key_name = var.key_name
  
  # User data
  user_data = templatefile("${path.module}/scripts/user-data.sh", {
    repo_url = var.repo_url
  })
  
  tags = merge(var.tags, {
    Role = "web-server"
  })
}
```

### Deploy VPC

```hcl
module "vpc" {
  source = "github.com/v-grand/infra-network//modules/vpc-aws"
  
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  enable_nat_gateway   = true
  enable_dns_hostnames = true
  
  tags = var.tags
}
```

### Deploy RDS Database

```hcl
module "database" {
  source = "github.com/v-grand/infra-core//modules/db"
  
  cloud = "aws"
  
  # Instance configuration
  identifier     = "myapp-db"
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = "db.t3.medium"
  
  # Storage
  allocated_storage     = 100
  max_allocated_storage = 500
  storage_encrypted     = true
  
  # Database
  db_name  = "myapp"
  username = "admin"
  password = var.db_password  # Use secrets manager
  
  # Network
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  # Security
  allowed_cidr_blocks = [var.vpc_cidr]
  
  # Backup
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  
  # High Availability
  multi_az               = true
  deletion_protection    = true
  
  tags = var.tags
}
```

## 🔒 Security Configuration

### Security Groups

```hcl
# Web server security group
resource "aws_security_group" "web" {
  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = module.vpc.vpc_id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (restricted)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "web-server-sg"
  })
}
```

### IAM Roles

```hcl
# EC2 instance role
resource "aws_iam_role" "ec2_role" {
  name = "ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policies
resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
```

## 🔗  Integration Examples

### With infra-monitoring

```hcl
# Deploy monitoring
module "monitoring" {
  source = "github.com/v-grand/infra-monitoring//modules/prometheus"
  
  # AWS specific configuration
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]
  
  instance_type = "t3.medium"
  
  # Scrape targets
  scrape_targets = [
    module.web_server.instance_private_ip
  ]
}
```

### With infra-secrets

```hcl
# Store secrets in AWS Secrets Manager
module "secrets" {
  source = "github.com/v-grand/infra-secrets//modules/aws-secrets"
  
  secrets = {
    db_password = {
      secret_string           = var.db_password
      recovery_window_in_days = 30
    }
  }
}
```

## 📚 Best Practices

1. **Multi-AZ Deployment** - Deploy across multiple availability zones
2. **Encrypted Storage** - Enable encryption for EBS and RDS
3. **IAM Least Privilege** - Minimal required permissions
4. **VPC Flow Logs** - Enable for network monitoring
5. **CloudWatch Alarms** - Set up monitoring alerts
6. **Backup Strategy** - Regular automated snapshots
7. **Cost Optimization** - Use reserved instances, spot instances
8. **Tagging Strategy** - Consistent resource tagging

## 🔧 Operations

### Connect to Instance

```bash
# Get instance IP
terraform output instance_public_ip

# SSH connection
ssh -i ~/.ssh/your-key.pem ec2-user@INSTANCE_IP

# Or use SSH config
cp ops/ssh_config.example ~/.ssh/config
# Edit config with your IP
ssh devml
```

### Backup and Recovery

```bash
# Create snapshot
aws ec2 create-snapshot \
  --volume-id vol-xxxxx \
  --description "Manual backup"

# Create AMI
aws ec2 create-image \
  --instance-id i-xxxxx \
  --name "web-server-backup-$(date +%Y%m%d)"
```

## 📖 Documentation

- [AWS Well-Architected](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)

## 🔗 Related Repositories

- [infra-core](infra-core.md) - Reusable Terraform modules
- [infra-network](infra-network.md) - Network configuration
- [infra-monitoring](infra-monitoring.md) - Monitoring setup
- [infra-secrets](infra-secrets.md) - Secrets management

