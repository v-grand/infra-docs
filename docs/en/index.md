# Welcome to Infra Docs

Welcome to the comprehensive documentation for the **v-grand infrastructure ecosystem**. This suite of repositories provides a complete, production-ready infrastructure-as-code (IaC) solution for multi-cloud deployments.

## 📚 Architecture Overview

The infrastructure ecosystem is built on a modular architecture where each repository serves a specific purpose:

```
┌─────────────────────┐
│    infra-docs       │  ← Documentation & Examples
└─────────────────────┘
          │
          ├─► infra-core       (Reusable Terraform Modules)
          ├─► infra-template   (Project Template)
          ├─► infra-ci         (CI/CD Workflows)
          │
          └─► Application Repositories:
              ├─► infra-aws        (AWS Infrastructure)
              ├─► infra-gcp        (GCP Infrastructure)
              ├─► infra-network    (Network Configuration)
              ├─► infra-monitoring (Observability Stack)
              ├─► infra-secrets    (Secrets Management)
              └─► infra-k8s        (Kubernetes Clusters)
```

## 🗂️ Repository Guide

### Core Libraries

| Repository | Purpose | Status |
|:-----------|:--------|:-------|
| **[infra-core](infra-core.md)** | Reusable Terraform modules (VM, VPC, DB, K8s, Tailscale) | ✅ Active |
| **[infra-template](https://github.com/v-grand/infra-template)** | Standardized template for new infrastructure projects | ✅ Active |
| **[infra-ci](https://github.com/v-grand/infra-ci)** | Reusable GitHub Actions workflows for CI/CD | ✅ Active |
| **[infra-docs](https://github.com/v-grand/infra-docs)** | Documentation website (this site) | ✅ Active |

### Cloud Infrastructure

| Repository | Purpose | Supported Clouds |
|:-----------|:--------|:-----------------|
| **[infra-aws](aws.md)** | AWS infrastructure deployment | AWS |
| **[infra-gcp](gcp/index.md)** | GCP infrastructure deployment | GCP |
| **[infra-network](https://github.com/v-grand/infra-network)** | VPC, VPN, Tailscale mesh networking | AWS, GCP |

### Platform Services

| Repository | Purpose | Key Technologies |
|:-----------|:--------|:----------------|
| **[infra-monitoring](https://github.com/v-grand/infra-monitoring)** | Observability & logging stack | Prometheus, Grafana, Loki |
| **[infra-secrets](https://github.com/v-grand/infra-secrets)** | Centralized secrets management | Vault, SOPS, GCP Secrets |
| **[infra-k8s](https://github.com/v-grand/infra-k8s)** | Kubernetes cluster management | GKE, EKS, K3s |

## 🚀 Quick Start

### For New Projects

1. **Clone the template:**
   ```bash
   git clone https://github.com/v-grand/infra-template.git my-new-project
   cd my-new-project
   ```

2. **Configure your environment:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your settings
   ```

3. **Deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### For Existing Projects

Choose the appropriate repository based on your needs:

- **AWS Deployment** → [infra-aws](aws.md)
- **GCP Deployment** → [infra-gcp](gcp/index.md)
- **Kubernetes** → [infra-k8s](https://github.com/v-grand/infra-k8s)
- **Monitoring** → [infra-monitoring](https://github.com/v-grand/infra-monitoring)

## 📖 Documentation Structure

- **[Infra Core Modules](infra-core.md)** - Detailed module documentation
- **[AWS Examples](examples/aws-dev.md)** - AWS deployment examples
- **[GCP Guides](gcp/index.md)** - GCP-specific documentation
- **[Tailscale Integration](tailscale.md)** - Mesh networking setup
- **[Notebooks](../../notebooks/)** - Interactive examples and tutorials

## 🔗 External Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Google Cloud Architecture Center](https://cloud.google.com/architecture)

## 🤝 Contributing

We welcome contributions! Please see the individual repository guidelines for contribution instructions.

## 📄 License

All repositories are licensed under the MIT License unless otherwise specified.
