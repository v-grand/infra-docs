# infra-network: Network Infrastructure

**infra-network** provides comprehensive network infrastructure modules including VPC configuration, VPN setup, and Tailscale mesh networking across cloud providers.

## 🎯 Purpose

This repository manages network infrastructure:

- **VPC Configuration** - Virtual Private Clouds for AWS and GCP
- **VPN Setup** - Site-to-site and client VPN configurations
- **Tailscale Integration** - Zero-config mesh networking
- **Multi-Cloud Networking** - Consistent networking across clouds

## 📁 Repository Structure

```
infra-network/
├── modules/
│   ├── vpc-aws/              # AWS VPC module
│   ├── vpc-gcp/              # GCP VPC module
│   ├── vpn/                  # VPN configurations
│   └── tailscale/            # Tailscale mesh networking
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars.example
│   │   └── backend.tf
│   └── prod/
│       └── ...
├── .github/
│   └── workflows/
│       └── deploy.yml        # CI/CD pipeline
└── README.md
```

## 🌐 Modules

### 1. VPC Module (AWS)

Create AWS Virtual Private Clouds with subnets, route tables, and internet gateways.

**Example Usage:**
```hcl
module "vpc_aws" {
  source = "github.com/v-grand/infra-network//modules/vpc-aws"
  
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  
  enable_nat_gateway = true
  enable_dns_hostnames = true
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### 2. VPC Module (GCP)

Create GCP Virtual Private Clouds with custom subnets and firewall rules.

**Example Usage:**
```hcl
module "vpc_gcp" {
  source = "github.com/v-grand/infra-network//modules/vpc-gcp"
  
  project_id   = "my-gcp-project"
  network_name = "main-vpc"
  
  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "us-central1"
    },
    {
      subnet_name   = "subnet-02"
      subnet_ip     = "10.10.20.0/24"
      subnet_region = "us-east1"
    }
  ]
  
  firewall_rules = [
    {
      name        = "allow-ssh"
      direction   = "INGRESS"
      ranges      = ["0.0.0.0/0"]
      allow_ports = ["22"]
      protocol    = "tcp"
    }
  ]
}
```

### 3. VPN Module

Configure site-to-site VPN connections between clouds.

**Example Usage:**
```hcl
module "vpn" {
  source = "github.com/v-grand/infra-network//modules/vpn"
  
  vpn_type = "site-to-site"
  
  local_network  = "10.0.0.0/16"
  remote_network = "10.10.0.0/16"
  
  peer_ip_address = "203.0.113.1"
  shared_secret   = var.vpn_shared_secret
  
  tags = {
    Environment = "production"
  }
}
```

### 4. Tailscale Module

Deploy Tailscale for zero-config mesh networking.

**Example Usage:**
```hcl
module "tailscale" {
  source = "github.com/v-grand/infra-network//modules/tailscale"
  
  auth_key    = var.tailscale_auth_key
  hostname    = "app-server-01"
  advertise_routes = ["10.0.0.0/16"]
  accept_routes    = true
  
  enable_ssh = true
}
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/v-grand/infra-network.git
cd infra-network
```

### 2. Configure Environment

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
# AWS Configuration
aws_region = "us-east-1"
vpc_cidr   = "10.0.0.0/16"

# GCP Configuration
gcp_project = "my-project-id"
gcp_region  = "us-central1"

# Tailscale
tailscale_auth_key = "tskey-xxxxxxxxxxxxx"
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

## 🔐 Security Configuration

### Firewall Rules

**AWS Security Groups:**
```hcl
resource "aws_security_group" "web" {
  name        = "web-server"
  description = "Allow HTTP/HTTPS inbound traffic"
  vpc_id      = module.vpc_aws.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**GCP Firewall Rules:**
```hcl
resource "google_compute_firewall" "web" {
  name    = "allow-web"
  network = module.vpc_gcp.network_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}
```

## 📊 Network Architecture

### Multi-Cloud Design

```
┌─────────────────────────────────────────────────┐
│             Tailscale Mesh Network              │
│                 (10.100.0.0/16)                 │
└─────────────────────────────────────────────────┘
                    ▲         ▲
                    │         │
         ┌──────────┘         └──────────┐
         │                                │
    ┌────┴─────┐                    ┌────┴─────┐
    │   AWS    │                    │   GCP    │
    │   VPC    │◄───── VPN ────────►│   VPC    │
    │10.0.0.0/16                    │10.10.0.0/16
    └──────────┘                    └──────────┘
```

## 🔗 Integration Examples

### With infra-aws

```hcl
# infra-aws/main.tf
module "network" {
  source = "github.com/v-grand/infra-network//modules/vpc-aws"
  
  vpc_cidr = var.vpc_cidr
  # ... configuration
}

module "app_server" {
  source = "github.com/v-grand/infra-core//modules/vm"
  
  subnet_id         = module.network.public_subnet_ids[0]
  security_group_id = module.network.default_security_group_id
  # ... configuration
}
```

### With infra-gcp

```hcl
# infra-gcp/main.tf
module "network" {
  source = "github.com/v-grand/infra-network//modules/vpc-gcp"
  
  project_id = var.gcp_project_id
  # ... configuration
}

module "app_server" {
  source = "github.com/v-grand/infra-core//modules/vm"
  
  network    = module.network.network_name
  subnetwork = module.network.subnet_names[0]
  # ... configuration
}
```

## 📚 Best Practices

1. **CIDR Planning** - Plan IP ranges carefully to avoid conflicts
2. **Subnet Segmentation** - Separate public/private/data subnets
3. **NAT Gateways** - Use NAT for private subnet internet access
4. **VPN Encryption** - Always use strong encryption for VPN
5. **Tailscale ACLs** - Configure access control lists properly
6. **Transit Gateways** - For complex multi-VPC architectures

## 🛠️ Variables

### Common Variables

| Variable | Description | Default |
|:---------|:------------|:--------|
| `vpc_cidr` | CIDR block for VPC | `10.0.0.0/16` |
| `availability_zones` | List of AZs | `[]` |
| `enable_nat_gateway` | Enable NAT gateway | `true` |
| `enable_vpn_gateway` | Enable VPN gateway | `false` |
| `tailscale_auth_key` | Tailscale authentication key | `""` |

## 📖 Documentation

- [VPC Design Patterns](https://aws.amazon.com/vpc/)
- [GCP Networking](https://cloud.google.com/vpc/docs)
- [Tailscale Documentation](https://tailscale.com/kb/)

## 🔗 Related Repositories

- [infra-core](infra-core.md) - Reusable Terraform modules
- [infra-aws](aws.md) - AWS infrastructure
- [infra-gcp](gcp/index.md) - GCP infrastructure
- [infra-monitoring](https://github.com/v-grand/infra-monitoring) - Connect monitoring across networks
