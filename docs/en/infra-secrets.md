# infra-secrets: Secrets Management

**infra-secrets** provides centralized, secure secrets management using HashiCorp Vault, SOPS, and cloud-native secret managers.

## 🎯 Purpose

Centralize and secure sensitive data:

- **HashiCorp Vault** - Dynamic secrets and encryption
- **SOPS** - Encrypted file storage with version control
- **GCP Secret Manager** - Native GCP secrets integration
- **AWS Secrets Manager** - Native AWS secrets integration

## 📁 Repository Structure

```
infra-secrets/
├── modules/
│   ├── vault/              # HashiCorp Vault deployment
│   ├── sops/               # SOPS integration
│   ├── gcp-secrets/        # GCP Secret Manager
│   └── aws-secrets/        # AWS Secrets Manager
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars.example
│   │   ├── backend.tf
│   │   └── secrets.enc.yaml  # Encrypted secrets
│   └── prod/
│       └── ...
├── policies/               # Vault policies
├── scripts/
│   ├── vault-init.sh       # Vault initialization
│   ├── sops-encrypt.sh     # SOPS encryption helper
│   └── sops-decrypt.sh     # SOPS decryption helper
└── README.md
```

## 🔐 Modules

### 1. HashiCorp Vault

Enterprise-grade secrets management with dynamic secrets.

**Features:**
- KV Secrets Engine (v2)
- Dynamic secrets (AWS, GCP, databases)
- Transit encryption engine
- AppRole authentication
- Token-based auth
- Audit logging

**Example Deployment:**
```hcl
module "vault" {
  source = "github.com/v-grand/infra-secrets//modules/vault"
  
  mode = "ha"  # or "dev" for development
  
  # HA configuration
  storage_backend = "consul"
  consul_address  = "consul.example.com:8500"
  
  # Auto-unseal with GCP KMS
  auto_unseal = true
  kms_project = var.gcp_project
  kms_region  = "global"
  kms_keyring = "vault-keyring"
  kms_key     = "vault-key"
  
  # TLS configuration
  tls_cert_file = "/vault/tls/vault.crt"
  tls_key_file  = "/vault/tls/vault.key"
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

**Vault Policy Example:**
```hcl
# policies/app-policy.hcl
path "secret/data/app/*" {
  capabilities = ["read", "list"]
}

path "database/creds/app-db" {
  capabilities = ["read"]
}

path "transit/encrypt/app" {
  capabilities = ["update"]
}

path "transit/decrypt/app" {
  capabilities = ["update"]
}
```

### 2. SOPS (Secrets OPerationS)

Encrypt files with AWS KMS, GCP KMS, or Age.

**Features:**
- YAML/JSON/ENV file encryption
- Partial encryption (only values)
- Multiple KMS support
- Git-friendly diffs
- CI/CD integration

**Example Usage:**

Create `.sops.yaml`:
```yaml
creation_rules:
  - path_regex: environments/prod/.*\.yaml$
    kms: 'arn:aws:kms:us-east-1:123456789:key/12345678-1234-1234-1234-123456789012'
    pgp: 'FBC7B9E2A4F9289AC0C1D4843D16CEE4A27381B4'
  
  - path_regex: environments/dev/.*\.yaml$
    age: 'age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p'
```

Encrypt secrets:
```bash
# Create secrets file
cat > secrets.yaml << EOF
database:
  host: db.example.com
  username: admin
  password: super-secret-password
  
api_keys:
  stripe: sk_live_xxxxxxxxxxxxx
  sendgrid: SG.xxxxxxxxxxxxx
EOF

# Encrypt with SOPS
sops -e secrets.yaml > secrets.enc.yaml

# Commit encrypted file
git add secrets.enc.yaml
git commit -m "Add encrypted secrets"
```

Decrypt and use:
```bash
# Decrypt in CI/CD
sops -d secrets.enc.yaml > secrets.yaml

# Or export as environment variables
export $(sops -d --output-type dotenv secrets.enc.yaml)
```

### 3. GCP Secret Manager

Native GCP secrets management.

**Example:**
```hcl
module "gcp_secrets" {
  source = "github.com/v-grand/infra-secrets//modules/gcp-secrets"
  
  project_id = var.gcp_project_id
  
  secrets = {
    database_password = {
      secret_data = var.database_password
      replication = "automatic"
      
      iam_members = [
        "serviceAccount:app@project.iam.gserviceaccount.com"
      ]
    }
    
    api_key = {
      secret_data = var.api_key
      replication = "automatic"
      rotation_period = "2592000s"  # 30 days
    }
  }
}
```

**Access from Application:**
```python
from google.cloud import secretmanager

def access_secret(project_id, secret_id, version_id="latest"):
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/{version_id}"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")

# Usage
db_password = access_secret("my-project", "database_password")
```

### 4. AWS Secrets Manager

Native AWS secrets management.

**Example:**
```hcl
module "aws_secrets" {
  source = "github.com/v-grand/infra-secrets//modules/aws-secrets"
  
  secrets = {
    database_credentials = {
      secret_string = jsonencode({
        username = "admin"
        password = var.database_password
        host     = "db.example.com"
        port     = 5432
      })
      
      recovery_window_in_days = 30
      rotation_enabled        = true
      rotation_days           = 30
    }
    
    api_key = {
      secret_string = var.api_key
      
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              AWS = "arn:aws:iam::123456789:role/app-role"
            }
            Action   = "secretsmanager:GetSecretValue"
            Resource = "*"
          }
        ]
      })
    }
  }
}
```

## 🚀 Quick Start

### 1. Initialize Vault

```bash
# Deploy Vault
cd environments/prod
terraform init
terraform apply

# Initialize Vault (first time only)
./scripts/vault-init.sh

# Save root token and unseal keys securely!
```

### 2. Configure SOPS

```bash
# Generate Age key
age-keygen -o ~/.config/sops/age/keys.txt

# Or use existing KMS keys
export SOPS_KMS_ARN="arn:aws:kms:us-east-1:123456789:key/xxxxx"
export SOPS_GCP_KMS="projects/my-project/locations/global/keyRings/my-keyring/cryptoKeys/my-key"
```

### 3. Store Secrets

**Using Vault:**
```bash
# Write secret
vault kv put secret/app/database \
  username=admin \
  password=super-secret

# Read secret
vault kv get secret/app/database
```

**Using SOPS:**
```bash
# Encrypt file
sops -e config.yaml > config.enc.yaml

# Edit encrypted file
sops config.enc.yaml

# Decrypt
sops -d config.enc.yaml
```

## 🔗 CI/CD Integration

### GitHub Actions with SOPS

```yaml
name: Deploy with Secrets
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install SOPS
        run: |
          wget https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux
          chmod +x sops-v3.7.3.linux
          sudo mv sops-v3.7.3.linux /usr/local/bin/sops
      
      - name: Decrypt Secrets
        env:
          SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY }}
        run: |
          sops -d environments/prod/secrets.enc.yaml > secrets.yaml
      
      - name: Deploy
        run: |
          terraform init
          terraform apply -auto-approve
```

### Using Vault in CI/CD

```yaml
name: Deploy with Vault
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Import Secrets from Vault
        uses: hashicorp/vault-action@v2
        with:
          url: https://vault.example.com
          token: ${{ secrets.VAULT_TOKEN }}
          secrets: |
            secret/data/app/database username | DATABASE_USERNAME ;
            secret/data/app/database password | DATABASE_PASSWORD ;
            secret/data/app/api apikey | API_KEY
      
      - name: Deploy
        run: |
          terraform apply -auto-approve
```

## 🔐 Security Best Practices

1. **Never commit unencrypted secrets** to version control
2. **Rotate secrets regularly** - Implement automatic rotation
3. **Use least privilege** - Grant minimal necessary access
4. **Audit access** - Enable and monitor audit logs
5. **Encrypt in transit** - Always use TLS/HTTPS
6. **Backup securely** - Encrypt Vault backups
7. **Multi-factor auth** - Enable MFA for Vault access

## 📊 Integration Examples

### With infra-aws

```hcl
# Retrieve secrets from Vault for AWS deployment
data "vault_generic_secret" "aws_credentials" {
  path = "secret/aws/credentials"
}

module "app_server" {
  source = "github.com/v-grand/infra-core//modules/vm"
  
  # Use dynamic credentials
  aws_access_key = data.vault_generic_secret.aws_credentials.data["access_key"]
  aws_secret_key = data.vault_generic_secret.aws_credentials.data["secret_key"]
}
```

### With infra-monitoring

```hcl
# Store Grafana admin password in Vault
resource "vault_generic_secret" "grafana_admin" {
  path = "secret/monitoring/grafana"
  
  data_json = jsonencode({
    admin_password = random_password.grafana_admin.result
  })
}

module "monitoring" {
  source = "github.com/v-grand/infra-monitoring//modules/grafana"
  
  admin_password = vault_generic_secret.grafana_admin.data["admin_password"]
}
```

## 📚 Documentation

- [HashiCorp Vault](https://www.vaultproject.io/docs)
- [SOPS](https://github.com/mozilla/sops)
- [GCP Secret Manager](https://cloud.google.com/secret-manager/docs)
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/)

## 🔗 Related Repositories

- [infra-ci](infra-ci.md) - CI/CD integration
- [infra-core](infra-core.md) - Infrastructure modules
- [infra-aws](aws.md) - AWS integration
- [infra-gcp](gcp/index.md) - GCP integration
