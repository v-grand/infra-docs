# infra-template: Project Template

**infra-template** provides a standardized starting point for new infrastructure projects with best practices, CI/CD integration, and consistent structure.

## 🎯 Purpose

Bootstrap new infrastructure projects:

- **Standardized Structure** - Consistent project layout
- **Best Practices** - Security, modularity, documentation
- **CI/CD Ready** - Pre-configured GitHub Actions
- **Multi-Cloud** - Support for AWS and GCP
- **Documentation** - Comprehensive templates

## 📁 Repository Structure

```
infra-template/
├── .github/
│   └── workflows/
│       ├── validate.yml       # Terraform validation
│       └── deploy.yml         # Automated deployment
├── modules/
│   └── vm/                    # Example local module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── examples/
│   ├── simple-vm/             # Basic VM deployment
│   └── multi-tier/            # Multi-tier architecture
├── docs/
│   ├── README.md              # Detailed documentation
│   ├── ARCHITECTURE.md        # Architecture decisions
│   └── DEPLOYMENT.md          # Deployment guide
├── main.tf                    # Root Terraform configuration
├── variables.tf               # Input variables
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Example variables
├── backend.tf                 # Backend configuration
├── versions.tf                # Provider versions
├── .gitignore                 # Git ignore rules
├── .terraform-docs.yml        # terraform-docs config
├── .pre-commit-config.yaml    # Pre-commit hooks
└── README.md                  # Project overview
```

## 🚀 Getting Started

### 1. Create New Project from Template

**Using GitHub:**
```bash
# Click "Use this template" on GitHub
# Or clone directly:
git clone https://github.com/v-grand/infra-template.git my-new-project
cd my-new-project

# Remove git history
rm -rf .git
git init
git add .
git commit -m "Initial commit from template"
```

### 2. Configure Project

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your settings
nano terraform.tfvars
```

**terraform.tfvars example:**
```hcl
# Project Configuration
project_name = "my-app"
environment  = "dev"

# Cloud Provider (aws or gcp)
cloud = "gcp"

# GCP Configuration
gcp_project = "my-gcp-project"
gcp_region  = "us-central1"
gcp_zone    = "us-central1-a"

# AWS Configuration
aws_region = "us-east-1"

# Network Configuration
vpc_cidr = "10.0.0.0/16"

# Compute Configuration
instance_type = "e2-medium"  # GCP
# instance_type = "t3.medium"  # AWS

# Tags
tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Project     = "my-app"
}
```

### 3. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply configuration
terraform apply
```

## 📝 Template Files

### main.tf

```hcl
# Main Terraform configuration
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider configuration
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

provider "aws" {
  region = var.aws_region
}

# Example: Use infra-core modules
module "vm" {
  source = "github.com/v-grand/infra-core//modules/vm"
  
  cloud         = var.cloud
  instance_name = "${var.project_name}-${var.environment}"
  instance_type = var.instance_type
  
  # GCP specific
  project = var.cloud == "gcp" ? var.gcp_project : null
  zone    = var.cloud == "gcp" ? var.gcp_zone : null
  
  # AWS specific
  subnet_id = var.cloud == "aws" ? var.aws_subnet_id : null
  
  tags = var.tags
}
```

### variables.tf

```hcl
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "cloud" {
  description = "Cloud provider (aws or gcp)"
  type        = string
  default     = "gcp"
  
  validation {
    condition     = contains(["aws", "gcp"], var.cloud)
    error_message = "Cloud must be aws or gcp."
  }
}

variable "gcp_project" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

### outputs.tf

```hcl
output "instance_id" {
  description = "ID of the created instance"
  value       = module.vm.instance_id
}

output "instance_ip" {
  description = "IP address of the instance"
  value       = module.vm.instance_ip
}

output "instance_name" {
  description = "Name of the instance"
  value       = module.vm.instance_name
}
```

### backend.tf

```hcl
# Terraform state backend configuration
terraform {
  backend "gcs" {
    bucket  = "my-terraform-state-bucket"
    prefix  = "terraform/state"
  }
  
  # Alternative: AWS S3 backend
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}
```

## 🔄 CI/CD Configuration

### .github/workflows/validate.yml

```yaml
name: Terraform Validation
on:
 [pull_request, push]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Format
        run: terraform fmt -check -recursive
      
      - name: Terraform Init
        run: terraform init -backend=false
      
      - name: Terraform Validate
        run: terraform validate
```

### .github/workflows/deploy.yml

```yaml
name: Deploy Infrastructure
on:
  push:
    branches: [main]

jobs:
  deploy:
    uses: v-grand/infra-ci/.github/workflows/reusable/terraform-apply.yml@main
    with:
      working-directory: ./
      environment: dev
    secrets:
      GCP_CREDENTIALS: ${{ secrets.GCP_CREDENTIALS }}
```

## 🔧 Pre-commit Hooks

### .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
        args:
          - --hook-config=--path-to-file=README.md
          - --hook-config=--add-to-existing-file=true
          - --hook-config=--create-file-if-not-exist=true
      - id: terraform_tflint
        args:
          - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
```

**Setup:**
```bash
# Install pre-commit
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

## 📚 Documentation Templates

### README.md Template

```markdown
# Project Name

Brief description of what this infrastructure deploys.

## Architecture

[Add architecture diagram here]

## Prerequisites

- Terraform >= 1.5.0
- GCP/AWS account with appropriate permissions
- [Other requirements]

## Quick Start

1. Clone repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Edit `terraform.tfvars` with your configuration
4. Run `terraform init && terraform apply`

## Configuration

[Document key variables and their purposes]

## Deployment

[Step-by-step deployment instructions]

## Maintenance

[Ongoing maintenance tasks]

## Troubleshooting

[Common issues and solutions]
```

## 🎨 Customization

### Add Custom Modules

```bash
# Create new module
mkdir -p modules/my-module
cd modules/my-module

# Create module files
cat > main.tf << EOF
# Module implementation
EOF

cat > variables.tf << EOF
# Module variables
EOF

cat > outputs.tf << EOF
# Module outputs
EOF

cat > README.md << EOF
# My Module

Description of the module
EOF
```

### Integrate with infra-core

```hcl
# Use existing infra-core modules
module "database" {
  source = "github.com/v-grand/infra-core//modules/db"
  
  # Configuration
}

module "network" {
  source = "github.com/v-grand/infra-network//modules/vpc-gcp"
  
  # Configuration
}
```

## ✅ Best Practices Included

1. **Version Pinning** - Terraform and provider versions locked
2. **Input Validation** - Variable validation rules
3. **Output Documentation** - Descriptive output values
4. **Code Formatting** - automated with pre-commit
5. **Security** - .gitignore prevents secret commits
6. **CI/CD** - Automated validation and deployment
7. **Documentation** - terraform-docs integration
8. **State Management** - Remote backend configuration

## 🔗 Integration

### With Other Repositories

```hcl
# Reference infra-core modules
module "vm" {
  source = "github.com/v-grand/infra-core//modules/vm"
}

# Use infra-network modules
module "vpc" {
  source = "github.com/v-grand/infra-network//modules/vpc-gcp"
}

# Integrate monitoring
module "monitoring" {
  source = "github.com/v-grand/infra-monitoring//modules/prometheus"
}
```

## 📖 Documentation

- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [infra-core Modules](infra-core.md)
- [CI/CD Workflows](infra-ci.md)

## 🔗 Related Repositories

- [infra-core](infra-core.md) - Reusable modules
- [infra-ci](infra-ci.md) - CI/CD workflows
- [infra-docs](index.md) - Documentation
