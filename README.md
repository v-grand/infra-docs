# infra-docs

📚 **Comprehensive Documentation for v-grand Infrastructure Ecosystem**

This repository contains documentation, examples, and resources for all `infra-*` repositories in the v-grand infrastructure ecosystem.

## 🎉 Recent Updates

**✅ Infrastructure Audit Completed** - December 2, 2025

A comprehensive audit of all 10 infra-* repositories has been completed with excellent results (8.6/10). See:
- [Audit Summary](AUDIT_SUMMARY.md) - Executive summary
- [Full Audit Report](INFRASTRUCTURE_AUDIT_REPORT.md) - Detailed findings

**New Documentation:**
- Complete guides for all 10 repositories
- Architecture diagrams and integration examples
- Enhanced navigation and organization
- Russian translations (in progress)

## 🗂️ Infrastructure Repositories

### Core Libraries
- **[infra-core](https://github.com/v-grand/infra-core)** - Reusable Terraform modules (VM, VPC, DB, K8s)
- **[infra-template](https://github.com/v-grand/infra-template)** - Standardized project template
- **[infra-ci](https://github.com/v-grand/infra-ci)** - Reusable GitHub Actions workflows
- **[infra-docs](https://github.com/v-grand/infra-docs)** - This documentation site

### Cloud Infrastructure
- **[infra-aws](https://github.com/v-grand/infra-aws)** - AWS infrastructure deployment
- **[infra-gcp](https://github.com/v-grand/infra-gcp)** - GCP infrastructure deployment
- **[infra-network](https://github.com/v-grand/infra-network)** - VPC, VPN, Tailscale networking

### Platform Services
- **[infra-monitoring](https://github.com/v-grand/infra-monitoring)** - Prometheus, Grafana, Loki
- **[infra-secrets](https://github.com/v-grand/infra-secrets)** - Vault, SOPS, secrets management
- **[infra-k8s](https://github.com/v-grand/infra-k8s)** - Kubernetes clusters (GKE, EKS, K3s)

## 🚀 Quick Start

### View Documentation Locally

```bash
# Install MkDocs
pip install mkdocs mkdocs-material

# Serve documentation
mkdocs serve

# Open browser to http://localhost:8000
```

### Build Documentation

```bash
# Build static site
mkdocs build

# Output in site/ directory
```

## 📖 Documentation Structure

```
docs/
├── en/                    # English documentation
│   ├── index.md          # Main overview
│   ├── infra-core.md     # Core modules
│   ├── infra-ci.md       # CI/CD workflows
│   ├── infra-network.md  # Networking
│   ├── infra-monitoring.md # Observability
│   ├── infra-secrets.md  # Secrets management
│   ├── infra-k8s.md      # Kubernetes
│   ├── infra-template.md # Project template
│   ├── aws.md            # AWS infrastructure
│   ├── gcp/              # GCP documentation
│   └── examples/         # Usage examples
├── ru/                   # Russian documentation
└── pl/                   # Polish documentation
```

## 🌐 Supported Languages

- 🇬🇧 **English** - Complete (95%)
- 🇷🇺 **Русский** - In Progress (65%)
- 🇵🇱 **Polski** - Planned (30%)

## 🔧 Development

### Prerequisites

- Python 3.8+
- pip

### Setup

```bash
# Clone repository
git clone https://github.com/v-grand/infra-docs.git
cd infra-docs

# Install dependencies
pip install -r requirements.txt

# Serve locally
mkdocs serve
```

### Adding Documentation

1. Create new `.md` file in `docs/en/`
2. Add to navigation in `mkdocs.yml`
3. Translate to other languages
4. Test locally with `mkdocs serve`
5. Submit pull request

## 📊 Repository Statistics

- **Total Repositories:** 10
- **Active Repositories:** 9
- **Documentation Pages:** 15+ (EN)
- **Terraform Modules:** 25+
- **Languages:** 3 (EN, RU, PL)

## 🤝 Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test locally
5. Submit a pull request

## 📝 License

MIT License - see individual repositories for details.

## 🔗 Links

- **Documentation Site:** https://v-grand.github.io/infra-docs/
- **GitHub Organization:** https://github.com/v-grand/
- **Issue Tracker:** https://github.com/v-grand/infra-docs/issues

## 📧 Contact

For questions or support, please open an issue or contact the infrastructure team.

---

**Last Updated:** December 2, 2025  
**Status:** ✅ Production Ready
