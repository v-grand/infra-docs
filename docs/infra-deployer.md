# Infra Deployer Usage Guide

`infra-deployer` is an automation tool for deploying infrastructure across multiple cloud providers and environments.

## Overview

Infra Deployer provides a unified interface for deploying and managing infrastructure modules including:
- Core infrastructure (VPC, networking)
- Compute resources (VMs, Kubernetes clusters)
- Databases and storage
- Monitoring and observability
- Security and access control

## Installation

### Prerequisites

- Python 3.8+
- Terraform 1.0+
- Cloud provider CLI tools (AWS CLI, gcloud, etc.)

### Setup

```bash
git clone https://github.com/v-grand/infra-deployer.git
cd infra-deployer
pip install -r requirements.txt
```

### Configuration

Create a configuration file `config.yaml`:

```yaml
environments:
  dev:
    provider: aws
    region: us-east-1
    modules:
      - core
      - compute
  
  prod:
    provider: gcp
    region: us-central1
    modules:
      - core
      - compute
      - database
      - monitoring
```

## Usage

### Deploy All Modules

Deploy all configured modules for an environment:

```bash
python -m deploy.cli deploy all --env dev
```

### Deploy Specific Module

Deploy a single module:

```bash
python -m deploy.cli deploy core --env prod
```

### List Available Modules

```bash
python -m deploy.cli list
```

### Check Deployment Status

```bash
python -m deploy.cli status --env dev
```

### Update Existing Deployment

```bash
python -m deploy.cli update core --env prod
```

### Destroy Resources

Destroy specific module:

```bash
python -m deploy.cli destroy core --env dev
```

Destroy all modules:

```bash
python -m deploy.cli destroy all --env dev
```

## Module Structure

Each module follows this structure:

```
modules/
├── core/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── compute/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── database/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

## Advanced Features

### Dry Run

Preview changes without applying:

```bash
python -m deploy.cli deploy core --env dev --dry-run
```

### Parallel Deployment

Deploy multiple modules in parallel:

```bash
python -m deploy.cli deploy --modules core,compute,database --parallel
```

### Custom Variables

Override variables from command line:

```bash
python -m deploy.cli deploy core --env dev --var region=eu-west-1 --var instance_type=t3.large
```

### State Management

View current state:

```bash
python -m deploy.cli state show --env dev
```

Export state:

```bash
python -m deploy.cli state export --env dev --output state.json
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy Infrastructure

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install dependencies
        run: pip install -r requirements.txt
      
      - name: Deploy
        run: python -m deploy.cli deploy all --env prod
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## Best Practices

1. **Use environments** to separate dev, staging, and production
2. **Version control** your configuration files
3. **Test in dev** before deploying to production
4. **Use dry-run** to preview changes
5. **Enable state locking** to prevent concurrent modifications
6. **Tag resources** for better organization and cost tracking

## Troubleshooting

### Common Issues

**Module not found:**
```bash
# List available modules
python -m deploy.cli list
```

**Authentication errors:**
```bash
# Verify cloud provider credentials
aws sts get-caller-identity  # For AWS
gcloud auth list             # For GCP
```

**State conflicts:**
```bash
# Force unlock state
python -m deploy.cli state unlock --env dev
```

## Resources

- [GitHub Repository](https://github.com/v-grand/infra-deployer)
- [Module Documentation](https://github.com/v-grand/infra-deployer/tree/main/modules)
- [Examples](https://github.com/v-grand/infra-deployer/tree/main/examples)
