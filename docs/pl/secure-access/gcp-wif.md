# Bezpieczny dostęp do GCP z Workload Identity Federation

Ta metoda jest **zalecana** do konfiguracji CI/CD (np. GitHub Actions) i pozwala uzyskać tymczasowe dane uwierzytelniające GCP bez konieczności przechowywania długotrwałych kluczy konta usługi.

## Jak to działa

1.  **GitHub** generuje unikalny token OIDC dla każdego uruchomienia workflow.
2.  **GCP IAM** ufa GitHub jako dostawcy tożsamości poprzez Workload Identity Federation.
3.  GitHub Action przekazuje swój token OIDC do GCP.
4.  **GCP STS** weryfikuje token i, jeśli jest prawidłowy, wydaje tymczasowe dane uwierzytelniające dla workflow do personifikacji określonego konta usługi.

## Konfiguracja krok po kroku

### Krok 1: Włącz wymagane API

```bash
gcloud services enable iamcredentials.googleapis.com
gcloud services enable sts.googleapis.com
```

### Krok 2: Utwórz pulę Workload Identity

```bash
gcloud iam workload-identity-pools create "github-pool" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --display-name="GitHub Actions Pool"
```

### Krok 3: Utwórz dostawcę Workload Identity

```bash
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com"
```

### Krok 4: Utwórz konto usługi

```bash
gcloud iam service-accounts create github-actions-sa \
  --project="YOUR_PROJECT_ID" \
  --display-name="GitHub Actions Service Account"
```

Przyznaj niezbędne uprawnienia kontu usługi:

```bash
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
  --member="serviceAccount:github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"
```

### Krok 5: Zezwól puli Workload Identity na personifikację konta usługi

```bash
gcloud iam service-accounts add-iam-policy-binding \
  github-actions-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com \
  --project="YOUR_PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/v-grand/YOUR_REPO"
```

**Ważne**: Zamień `PROJECT_NUMBER` na numer projektu GCP (nie ID) i `v-grand/YOUR_REPO` na swoje repozytorium.

### Krok 6: Pobierz nazwę zasobu dostawcy Workload Identity

```bash
gcloud iam workload-identity-pools providers describe "github-provider" \
  --project="YOUR_PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --format="value(name)"
```

Zapisz tę wartość - będzie potrzebna w workflow GitHub Actions.

### Krok 7: Zaktualizuj workflow GitHub Actions

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
      id-token: write # Wymagane do uzyskania tokenu OIDC
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

Teraz nie potrzebujesz już plików kluczy konta usługi w swoim repozytorium!
