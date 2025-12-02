# infra-ci: CI/CD Workflows

**infra-ci** is a centralized repository containing reusable GitHub Actions workflows, pipeline templates, and automation utilities for infrastructure-as-code projects.

## 🎯 Purpose

This repository provides standardized CI/CD components that:

- **Unify CI/CD Processes** across all `infra-*` repositories
- **Simplify Maintenance** by centralizing pipeline logic
- **Enhance Security** with integrated secrets management
- **Accelerate Development** with ready-to-use templates

## 📁 Repository Structure

```
infra-ci/
├── .github/
│   └── workflows/
│       ├── validate.yml             # Terraform validation
│       ├── deploy.yml               # Deployment template
│       └── reusable/
│           ├── terraform-plan.yml   # Reusable Terraform plan
│           ├── terraform-apply.yml  # Reusable Terraform apply
│           └── sops-decrypt.yml     # SOPS secrets decryption
├── scripts/
│   ├── decrypt.sh                   # SOPS decryption script
│   └── lint.sh                      # Code formatting checks
├── templates/
│   └── README.template.md           # Module README template
├── docs/
│   └── ci-guide.md                  # Usage documentation
└── README.md
```

## 🔧 Core Features

### 1. Reusable Workflows

#### Terraform Plan Workflow
```yaml
# .github/workflows/reusable/terraform-plan.yml
name: Terraform Plan
on:
  workflow_call:
    inputs:
      working-directory:
        required: true
        type: string
      environment:
        required: true
        type: string
```

#### Terraform Apply Workflow
```yaml
# .github/workflows/reusable/terraform-apply.yml
name: Terraform Apply
on:
  workflow_call:
    inputs:
      working-directory:
        required: true
        type: string
```

#### SOPS Decryption Workflow
Decrypts sensitive files using SOPS before deployment.

### 2. Validation Pipeline

Performs automated checks:
- ✅ `terraform fmt` - Code formatting
- ✅ `terraform validate` - Configuration validation
- ✅ `tflint` - Linting (optional)

### 3. Security Features

- All secrets passed via GitHub Secrets
- SOPS file decryption via `age` or KMS
- Optional Tailscale connectivity for secure deployments

## 📖 Usage Examples

### Using Reusable Workflows in Your Repository

#### Example: infra-aws/.github/workflows/deploy.yml

```yaml
name: Deploy AWS Infrastructure
on:
  push:
    branches: [main]
  pull_request:

jobs:
  plan:
    uses: v-grand/infra-ci/.github/workflows/reusable/terraform-plan.yml@main
    with:
      working-directory: ./infra
      environment: dev
    secrets:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

  apply:
    needs: plan
    if: github.ref == 'refs/heads/main'
    uses: v-grand/infra-ci/.github/workflows/reusable/terraform-apply.yml@main
    with:
      working-directory: ./infra
      environment: dev
    secrets:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### Using SOPS Decryption

```yaml
name: Deploy with Secrets
on:
  push:
    branches: [main]

jobs:
  decrypt-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Decrypt Secrets
        uses: v-grand/infra-ci/.github/workflows/reusable/sops-decrypt.yml@main
        with:
          encrypted-file: secrets.enc.yaml
          age-key: ${{ secrets.AGE_SECRET_KEY }}
      
      - name: Deploy Infrastructure
        run: |
          terraform init
          terraform apply -auto-approve
```

## 🔑 Required GitHub Secrets

Configure these secrets in your repository settings:

### For AWS Deployments
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION` (optional)

### For GCP Deployments
- `GCP_CREDENTIALS` - Service account JSON
- `GCP_PROJECT_ID`
- `GCP_REGION`

### For SOPS Decryption
- `AGE_SECRET_KEY` - Age private key
- `SOPS_KMS_ARN` - AWS KMS key ARN (if using AWS KMS)
- `SOPS_GCP_KMS` - GCP KMS key (if using GCP KMS)

### For Tailscale (Optional)
- `TAILSCALE_AUTH_KEY` - Tailscale authentication key

## 🛡️ Security Best Practices

1. **Never commit secrets** - Always use GitHub Secrets or SOPS
2. **Use least privilege** - Grant minimal required permissions
3. **Enable branch protection** - Require PR reviews for `main`
4. **Rotate credentials** - Regularly update access keys
5. **Audit deployments** - Review workflow run logs

## 📚 Integration with Other Repositories

| Repository | Integration |
|:-----------|:-----------|
| **infra-aws** | Uses `terraform-plan` and `terraform-apply` workflows |
| **infra-gcp** | Uses reusable workflows with GCP credentials |
| **infra-k8s** | Integrates for Helm chart deployments |
| **infra-monitoring** | Uses validation workflows |
| **infra-secrets** | Uses SOPS decryption workflows |

## 🚀 Getting Started

### 1. Configure Your Repository

Add this workflow to your repository:

```bash
mkdir -p .github/workflows
cat > .github/workflows/deploy.yml << 'EOF'
name: Deploy Infrastructure
on:
  push:
    branches: [main]
  pull_request:

jobs:
  terraform:
    uses: v-grand/infra-ci/.github/workflows/reusable/terraform-plan.yml@main
    with:
      working-directory: ./
      environment: dev
EOF
```

### 2. Configure Secrets

Navigate to your repository → Settings → Secrets and add required secrets.

### 3. Push and Deploy

```bash
git add .github/workflows/deploy.yml
git commit -m "Add CI/CD pipeline"
git push
```

## 📊 Outcome

After implementation:
- ✅ Unified CI/CD pipelines across all repositories
- ✅ Simplified maintenance and updates
- ✅ Enhanced security with secrets management
- ✅ Faster project initiation

## 🔗 Related Documentation

- [Terraform Documentation](https://terraform.io/docs)
- [GitHub Actions](https://docs.github.com/en/actions)
- [SOPS](https://github.com/mozilla/sops)
- [Tailscale](https://tailscale.com/kb/)

## 📝 Additional Resources

- [CI Guide](https://github.com/v-grand/infra-ci/blob/main/docs/ci-guide.md)
- [Repository Template](https://github.com/v-grand/infra-template)
