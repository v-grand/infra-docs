# Secure AWS Access with OIDC

This method is **recommended** for setting up CI/CD (e.g., GitHub Actions) and allows you to obtain temporary AWS credentials without needing to store long-lived `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` in secrets.

## How It Works

1.  **GitHub** generates a unique OIDC token for each run of your workflow.
2.  **AWS IAM** trusts GitHub as an identity provider.
3.  GitHub Action passes its OIDC token to AWS.
4.  **AWS STS** (Security Token Service) validates the token and, if valid, issues temporary credentials to your workflow to assume the specified role.

## Step-by-Step Setup

### Step 1: Configure Identity Provider in AWS IAM

1.  Open the AWS console and navigate to the **IAM** service.
2.  In the left menu, select **Identity providers**.
3.  Click **"Add provider"**.
4.  Select provider type **"OpenID Connect"**.
5.  In the **Provider URL** field, enter `https://token.actions.githubusercontent.com`.
6.  Click **"Get thumbprint"** to allow AWS to automatically retrieve the certificate thumbprint.
7.  In the **Audience** field, enter `sts.amazonaws.com`.
8.  Click **"Add provider"**.

### Step 2: Create IAM Role

1.  In IAM, navigate to **Roles** and click **"Create role"**.
2.  For "Trusted entity type", select **"Web identity"**.
3.  In the **Identity provider** dropdown, select the provider you created in the previous step (`token.actions.githubusercontent.com`).
4.  In the **Audience** field, select `sts.amazonaws.com`.
5.  Click **"Next"**.
6.  On the next step, attach the necessary permission policies (e.g., `AdministratorAccess` for testing or more granular permissions for production).
7.  Give the role a name, for example, `GitHubActionsRole`.

### Step 3: Configure Trust Policy

1.  Open the role you created and go to the **"Trust relationships"** tab.
2.  Click **"Edit trust policy"**.
3.  Modify the `Condition` to restrict access only to your repository and branch. This is a **critical security step**.

    Example for repository `v-grand/my-project` and branch `main`:

    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::YOUR_AWS_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": {
                    "StringEquals": {
                        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                    },
                    "StringLike": {
                        "token.actions.githubusercontent.com:sub": "repo:v-grand/my-project:ref:refs/heads/main"
                    }
                }
            }
        ]
    }
    ```
    **Don't forget to replace `YOUR_AWS_ACCOUNT_ID` and `v-grand/my-project:ref:refs/heads/main` with your values!**

### Step 4: Update GitHub Actions Workflow

Now update your `.github/workflows/deploy-aws.yml` to use this role.

```yaml
name: Deploy to AWS via OIDC

# ...

jobs:
  deploy:
    name: Deploy to AWS
    runs-on: ubuntu-latest
    permissions:
      id-token: write # Required to obtain OIDC token
      contents: read

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        role-to-assume: arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/GitHubActionsRole # Replace with your role ARN
        aws-region: us-east-1

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      # ...
```

Now you no longer need `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` secrets in your repository!
