# infra-template: Шаблон проекта

**infra-template** предоставляет стандартизированную отправную точку для новых инфраструктурных проектов с лучшими практиками, интеграцией CI/CD и согласованной структурой.

## 🎯 Назначение

Запуск новых инфраструктурных проектов:

- **Стандартизированная структура** - Согласованная компоновка проекта
- **Лучшие практики** - Безопасность, модульность, документация
- **Готовность к CI/CD** - Предварительно настроенные GitHub Actions
- **Мультиоблачность** - Поддержка AWS и GCP
- **Документация** - Комплексные шаблоны

## 📁 Структура репозитория

```
infra-template/
├── .github/
│   └── workflows/
│       ├── validate.yml       # Валидация Terraform
│       └── deploy.yml         # Автоматическое развертывание
├── modules/
│   └── vm/                    # Пример локального модуля
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── examples/
│   ├── simple-vm/             # Базовое развертывание VM
│   └── multi-tier/            # Многоуровневая архитектура
├── docs/
│   ├── README.md              # Подробная документация
│   ├── ARCHITECTURE.md        # Архитектурные решения
│   └── DEPLOYMENT.md          # Руководство по развертыванию
├── main.tf                    # Корневая конфигурация Terraform
├── variables.tf               # Входные переменные
├── outputs.tf                 # Выходные значения
├── terraform.tfvars.example   # Пример переменных
├── backend.tf                 # Конфигурация бэкенда
├── versions.tf                # Версии провайдеров
├── .gitignore                 # Правила игнорирования Git
├── .terraform-docs.yml        # Конфигурация terraform-docs
├── .pre-commit-config.yaml    # Хуки pre-commit
└── README.md                  # Обзор проекта
```

## 🚀 Начало работы

### 1. Создание нового проекта из шаблона

**Использование GitHub:**
```bash
# Нажмите "Use this template" на GitHub
# Или клонируйте напрямую:
git clone https://github.com/v-grand/infra-template.git my-new-project
cd my-new-project

# Удалите историю Git
rm -rf .git
git init
git add .
git commit -m "Initial commit from template"
```

### 2. Настройка проекта

```bash
# Скопируйте пример конфигурации
cp terraform.tfvars.example terraform.tfvars

# Отредактируйте с вашими настройками
nano terraform.tfvars
```

**Пример terraform.tfvars:**
```hcl
# Конфигурация проекта
project_name = "my-app"
environment  = "dev"

# Облачный провайдер (aws или gcp)
cloud = "gcp"

# Конфигурация GCP
gcp_project = "my-gcp-project"
gcp_region  = "us-central1"
gcp_zone    = "us-central1-a"

# Конфигурация AWS
aws_region = "us-east-1"

# Конфигурация сети
vpc_cidr = "10.0.0.0/16"

# Конфигурация вычислений
instance_type = "e2-medium"  # GCP
# instance_type = "t3.medium"  # AWS

# Теги
tags = {
  Environment = "dev"
  ManagedBy   = "terraform"
  Project     = "my-app"
}
```

### 3. Инициализация и развертывание

```bash
# Инициализация Terraform
terraform init

# Просмотр плана
terraform plan

# Применение конфигурации
terraform apply
```

## 📝 Файлы шаблонов

### main.tf

```hcl
# Основная конфигурация Terraform
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Конфигурация провайдера
provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

provider "aws" {
  region = var.aws_region
}

# Пример: Использование модулей infra-core
module "vm" {
  source = "github.com/v-grand/infra-core//modules/vm"
  
  cloud         = var.cloud
  instance_name = "${var.project_name}-${var.environment}"
  instance_type = var.instance_type
  
  # Специфично для GCP
  project = var.cloud == "gcp" ? var.gcp_project : null
  zone    = var.cloud == "gcp" ? var.gcp_zone : null
  
  # Специфично для AWS
  subnet_id = var.cloud == "aws" ? var.aws_subnet_id : null
  
  tags = var.tags
}
```

### variables.tf

```hcl
variable "project_name" {
  description = "Название проекта"
  type        = string
}

variable "environment" {
  description = "Окружение (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Окружение должно быть dev, staging или prod."
  }
}

variable "cloud" {
  description = "Облачный провайдер (aws или gcp)"
  type        = string
  default     = "gcp"
  
  validation {
    condition     = contains(["aws", "gcp"], var.cloud)
    error_message = "Облако должно быть aws или gcp."
  }
}

variable "gcp_project" {
  description = "ID проекта GCP"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "Регион GCP"
  type        = string
  default     = "us-central1"
}

variable "tags" {
  description = "Теги для применения к ресурсам"
  type        = map(string)
  default     = {}
}
```

### outputs.tf

```hcl
output "instance_id" {
  description = "ID созданного экземпляра"
  value       = module.vm.instance_id
}

output "instance_ip" {
  description = "IP-адрес экземпляра"
  value       = module.vm.instance_ip
}

output "instance_name" {
  description = "Имя экземпляра"
  value       = module.vm.instance_name
}
```

### backend.tf

```hcl
# Конфигурация бэкенда состояния Terraform
terraform {
  backend "gcs" {
    bucket  = "my-terraform-state-bucket"
    prefix  = "terraform/state"
  }
  
  # Альтернатива: бэкенд AWS S3
  # backend "s3" {
  #   bucket         = "my-terraform-state-bucket"
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-locks"
  #   encrypt        = true
  # }
}
```

## 🔄 Конфигурация CI/CD

### .github/workflows/validate.yml

```yaml
name: Terraform Validation
on:
 [pull_request, push]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Format
        run: terraform fmt -check -recursive
      
      - name: Terraform Init
        run: terraform init -backend=false
      
      - name: Terraform Validate
        run: terraform validate
```

### .github/workflows/deploy.yml

```yaml
name: Deploy Infrastructure
on:
  push:
    branches: [main]

jobs:
  deploy:
    uses: v-grand/infra-ci/.github/workflows/reusable/terraform-apply.yml@main
    with:
      working-directory: ./
      environment: dev
    secrets:
      GCP_CREDENTIALS: ${{ secrets.GCP_CREDENTIALS }}
```

## 🔧 Хуки Pre-commit

### .pre-commit-config.yaml

```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
        args:
          - --hook-config=--path-to-file=README.md
          - --hook-config=--add-to-existing-file=true
          - --hook-config=--create-file-if-not-exist=true
      - id: terraform_tflint
        args:
          - --args=--config=__GIT_WORKING_DIR__/.tflint.hcl
```

**Настройка:**
```bash
# Установка pre-commit
pip install pre-commit

# Установка хуков
pre-commit install

# Запуск вручную
pre-commit run --all-files
```

## 📚 Шаблоны документации

### Шаблон README.md

```markdown
# Название проекта

Краткое описание того, что развертывает эта инфраструктура.

## Архитектура

[Добавьте здесь архитектурную диаграмму]

## Предварительные требования

- Terraform >= 1.5.0
- Учетная запись GCP/AWS с соответствующими разрешениями
- [Другие требования]

## Быстрый старт

1. Клонируйте репозиторий
2. Скопируйте `terraform.tfvars.example` в `terraform.tfvars`
3. Отредактируйте `terraform.tfvars` с вашей конфигурацией
4. Запустите `terraform init && terraform apply`

## Конфигурация

[Документируйте ключевые переменные и их назначение]

## Развертывание

[Пошаговые инструкции по развертыванию]

## Обслуживание

[Текущие задачи по обслуживанию]

## Устранение неполадок

[Распространенные проблемы и решения]
```

## 🎨 Кастомизация

### Добавление пользовательских модулей

```bash
# Создайте новый модуль
mkdir -p modules/my-module
cd modules/my-module

# Создайте файлы модуля
cat > main.tf << EOF
# Реализация модуля
EOF

cat > variables.tf << EOF
# Переменные модуля
EOF

cat > outputs.tf << EOF
# Выходные данные модуля
EOF

cat > README.md << EOF
# Мой модуль

Описание модуля
EOF
```

### Интеграция с infra-core

```hcl
# Использование существующих модулей infra-core
module "database" {
  source = "github.com/v-grand/infra-core//modules/db"
  
  # Конфигурация
}

module "network" {
  source = "github.com/v-grand/infra-network//modules/vpc-gcp"
  
  # Конфигурация
}
```

## ✅ Включенные лучшие практики

1. **Фиксация версий** - Версии Terraform и провайдеров зафиксированы
2. **Валидация ввода** - Правила валидации переменных
3. **Документация вывода** - Описательные выходные значения
4. **Форматирование кода** - Автоматизировано с помощью pre-commit
5. **Безопасность** - .gitignore предотвращает коммиты секретов
6. **CI/CD** - Автоматическая валидация и развертывание
7. **Документация** - Интеграция terraform-docs
8. **Управление состоянием** - Конфигурация удаленного бэкенда

## 🔗 Интеграция

### С другими репозиториями

```hcl
# Ссылка на модули infra-core
module "vm" {
  source = "github.com/v-grand/infra-core//modules/vm"
}

# Использование модулей infra-network
module "vpc" {
  source = "github.com/v-grand/infra-network//modules/vpc-gcp"
}

# Интеграция мониторинга
module "monitoring" {
  source = "github.com/v-grand/infra-monitoring//modules/prometheus"
}
```

## 📖 Документация

- [Лучшие практики Terraform](https://www.terraform-best-practices.com/)
- [Модули infra-core](infra-core.md)
- [Рабочие процессы CI/CD](infra-ci.md)

## 🔗 Связанные репозитории

- [infra-core](infra-core.md) - Переиспользуемые модули
- [infra-ci](infra-ci.md) - Рабочие процессы CI/CD
- [infra-docs](index.md) - Документация
