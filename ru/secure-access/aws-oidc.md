# Безопасный доступ к AWS с помощью OIDC

Этот метод является **рекомендуемым** для настройки CI/CD (например, GitHub Actions) и позволяет получить временные учетные данные AWS без необходимости хранить долгоживущие `AWS_ACCESS_KEY_ID` и `AWS_SECRET_ACCESS_KEY` в секретах.

## Принцип работы

1.  **GitHub** генерирует уникальный OIDC токен для каждого запуска вашего workflow.
2.  **AWS IAM** доверяет GitHub как провайдеру идентификации.
3.  GitHub Action передает свой OIDC токен в AWS.
4.  **AWS STS** (Security Token Service) проверяет токен и, если он валиден, выдает вашему workflow временные учетные данные для выполнения указанной роли.

## Пошаговая настройка

### Шаг 1: Настройка Identity Provider в AWS IAM

1.  Откройте консоль AWS и перейдите в сервис **IAM**.
2.  В левом меню выберите **Identity providers**.
3.  Нажмите **"Add provider"**.
4.  Выберите тип провайдера **"OpenID Connect"**.
5.  В поле **Provider URL** введите `https://token.actions.githubusercontent.com`.
6.  Нажмите **"Get thumbprint"**, чтобы AWS автоматически получил отпечаток сертификата.
7.  В поле **Audience** введите `sts.amazonaws.com`.
8.  Нажмите **"Add provider"**.

### Шаг 2: Создание IAM Role

1.  В IAM перейдите в раздел **Roles** и нажмите **"Create role"**.
2.  В качестве "Trusted entity type" выберите **"Web identity"**.
3.  В выпадающем списке **Identity provider** выберите провайдера, которого вы создали на предыдущем шаге (`token.actions.githubusercontent.com`).
4.  В поле **Audience** выберите `sts.amazonaws.com`.
5.  Нажмите **"Next"**.
6.  На следующем шаге прикрепите необходимые политики прав (например, `AdministratorAccess` для тестов или более гранулярные права для продакшена).
7.  Дайте роли имя, например, `GitHubActionsRole`.

### Шаг 3: Настройка Trust Policy

1.  Откройте созданную вами роль и перейдите на вкладку **"Trust relationships"**.
2.  Нажмите **"Edit trust policy"**.
3.  Измените `Condition`, чтобы ограничить доступ только до вашего репозитория и ветки. Это **критически важный шаг для безопасности**.

    Пример для репозитория `v-grand/my-project` и ветки `main`:

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
    **Не забудьте заменить `YOUR_AWS_ACCOUNT_ID` и `v-grand/my-project:ref:refs/heads/main` на ваши значения!**

### Шаг 4: Обновление GitHub Actions Workflow

Теперь обновите ваш `.github/workflows/deploy-aws.yml`, чтобы он использовал эту роль.

```yaml
name: Deploy to AWS via OIDC

# ...

jobs:
  deploy:
    name: Deploy to AWS
    runs-on: ubuntu-latest
    permissions:
      id-token: write # Необходимо для получения OIDC токена
      contents: read

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v1
      with:
        role-to-assume: arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/GitHubActionsRole # Замените на ARN вашей роли
        aws-region: us-east-1

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      # ...
```

Теперь вам больше не нужны секреты `AWS_ACCESS_KEY_ID` и `AWS_SECRET_ACCESS_KEY` в вашем репозитории!
