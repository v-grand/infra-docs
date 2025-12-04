# Secure GCP Access with Workload Identity Federation

This method is **recommended** for setting up CI/CD (e.g., GitHub Actions) and allows you to obtain temporary GCP credentials without needing to store long-lived service account keys.

## How It Works

1.  **GitHub** generates a unique OIDC token for each run of your workflow.
2.  **GCP IAM** trusts GitHub as an identity provider through Workload Identity Federation.
3.  GitHub Action passes its OIDC token to GCP.
4.  **GCP STS** validates the token and, if valid, issues temporary credentials to your workflow to impersonate the specified service account.

## Step-by-Step Setup

### Step 1: Enable Required APIs

```bash
gcloud services enable iamcredentials.googleapis.com
gcloud services enable sts.googleapis.com
```

### Step 2: Create Workload Identity Pool

```bash
gcloud iam workload-identity-pools create "github-pool" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --display-name="GitHub Actions Pool"
```

### Step 3: Create Workload Identity Provider

```bash
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

### Step 4: Create Service Account

```bash
gcloud iam service-accounts create github-actions-sa \
  --project="YOUR_PROJECT_ID" \
  --display-name="GitHub Actions Service Account"
```

Grant necessary permissions to the service account:

```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"
```

### Step 5: Allow Workload Identity Pool to Impersonate Service Account

```bash
gcloud iam service-accounts add-iam-policy-binding \
  github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --project="YOUR_PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/v-grand/YOUR_REPO"
```

**Important**: Replace `PROJECT_NUMBER` with your GCP project number (not ID) and `v-grand/YOUR_REPO` with your repository.

### Step 6: Get Workload Identity Provider Resource Name

```bash
gcloud iam workload-identity-pools providers describe "github-provider" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --format="value(name)"
```

Save this value - you'll need it in your GitHub Actions workflow.

### Step 7: Update GitHub Actions Workflow

```yaml
name: Deploy to GCP via WIF

on:
  push:
    branches: [main]

jobs:
  deploy:
    name: Deploy to GCP
    runs-on: ubuntu-latest
    permissions:
      id-token: write # Required to obtain OIDC token
      contents: read

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Authenticate to Google Cloud
      uses: google-github-actions/auth@v1
      with:
        workload_identity_provider: 'projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider'
        service_account: 'github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com'

    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v1

    - name: Use gcloud CLI
      run: gcloud info
```

## Security Best Practices

1. **Restrict by repository**: Use attribute conditions to limit access to specific repositories
2. **Restrict by branch**: Add branch conditions in the attribute mapping
3. **Least privilege**: Grant only necessary permissions to the service account
4. **Audit logs**: Enable and monitor Cloud Audit Logs for service account usage

## Troubleshooting

### Error: "Permission denied"
- Verify the service account has necessary permissions
- Check that the workload identity pool binding is correct

### Error: "Invalid token"
- Ensure `id-token: write` permission is set in the workflow
- Verify the issuer URI is correct

### Error: "Workload identity pool not found"
- Check that the pool and provider names match exactly
- Verify the project ID and number are correct

Now you no longer need service account key files in your repository!
