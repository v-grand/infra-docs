# Инфраструктура AWS

**infra-aws** управляет развертыванием инфраструктуры AWS с использованием модулей Terraform из infra-core, обеспечивая стандартизированное предоставление облачных ресурсов.

## 🎯 Назначение

Развертывание и управление инфраструктурой AWS:

- **EC2 Instances** - Развертывание виртуальных машин
- **VPC Configuration** - Сетевая инфраструктура
- **RDS Databases** - Управляемые базы данных
- **EKS Clusters** - Kubernetes на AWS
- **S3 Storage** - Объектное хранилище
- **IAM Policies** - Управление доступом

## 📁 Структура репозитория

```
infra-aws/
├── bootstrap/              # Начальная настройка AWS
│   ├── iam/               # Роли и политики IAM
│   ├── s3/                # S3 бакеты для состояния Terraform
│   └── dynamodb/          # DynamoDB для блокировки состояния
├── infra/                 # Основная инфраструктура
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   ├── backend.tf
│   └── outputs.tf
├── ops/                   # Операционные скрипты
│   ├── ssh_config.example
│   └── scripts/
├── ide/                   # Конфигурации IDE
└── README.md
```

## 🚀 Быстрый старт

### 1. Предварительные требования

- [Terraform](https://terraform.io/downloads) >= 1.5.0
- AWS CLI настроен с учетными данными
- Существующая пара ключей EC2 (или создайте новую)

```bash
# Настройте AWS CLI
aws configure

# Проверьте доступ
aws sts get-caller-identity
```

### 2. Загрузка инфраструктуры

```bash
# Клонируйте репозиторий
git clone https://github.com/v-grand/infra-aws.git
cd infra-aws

# Загрузка (только в первый раз)
cd bootstrap
terraform init
terraform apply

# Это создает:
# - S3 бакет для состояния Terraform
# - Таблицу DynamoDB для блокировки состояния
# - Базовые роли IAM
```

### 3. Развертывание основной инфраструктуры

```bash
cd ../infra

# Скопируйте пример конфигурации
cp terraform.tfvars.example terraform.tfvars

# Отредактируйте конфигурацию
nano terraform.tfvars
```

**Пример terraform.tfvars:**
```hcl
# Конфигурация AWS
aws_region = "us-east-1"
key_name   = "my-ec2-key"

# Конфигурация сети
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# Доступ по SSH
allowed_ssh_cidr = "YOUR_IP/32"  # Получить с помощью: curl ifconfig.me

# Приложение
repo_url    = "https://github.com/your-org/your-app.git"
repo_branch = "main"

# Теги
tags = {
  Environment = "dev"
  Project     = "my-app"
  ManagedBy   = "terraform"
}
```

```bash
# Развертывание
terraform init
terraform plan
terraform apply
```

## 🏗️ Архитектура

### Базовая архитектура

```
┌─────────────────────────────────────────────┐
│              Регион AWS (us-east-1)         │
│  ┌────────────────────────────────────────┐ │
│  │           VPC (10.0.0.0/16)            │ │
│  │  ┌──────────────┬──────────────────┐  │ │
│  │  │   AZ-1a      │      AZ-1b       │  │ │
│  │  │              │                  │  │ │
│  │  │  Публичная   │    Публичная     │  │ │
│  │  │  подсеть     │    подсеть       │  │ │
│  │  │  10.0.1/24   │    10.0.2/24     │  │ │
│  │  │  ┌────────┐  │   ┌────────┐     │  │ │
│  │  │  │  EC2   │  │   │  EC2   │     │  │ │
│  │  │  │  ALB   │  │   │  ALB   │     │  │ │
│  │  │  └────────┘  │   └────────┘     │  │ │
│  │  │              │                  │  │ │
│  │  │  Приватная   │    Приватная     │  │ │
│  │  │  подсеть     │    подсеть       │  │ │
│  │  │  10.0.10/24  │    10.0.11/24    │  │ │
│  │  │  ┌────────┐  │   ┌────────┐     │  │ │
│  │  │  │  RDS   │  │   │  RDS   │     │  │ │
│  │  │  │(Primary)│  │   │(Standby)│    │  │ │
│  │  │  └────────┘  │   └────────┘     │  │ │
│  │  └──────────────┴──────────────────┘  │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

## 📦 Использование модулей

### Развертывание экземпляра EC2

```hcl
module "web_server" {
  source = "github.com/v-grand/infra-core//modules/vm"
  
  cloud         = "aws"
  instance_name = "web-server"
  instance_type = "t3.medium"
  
  # Сеть
  subnet_id          = module.vpc.public_subnet_ids[0]
  security_group_ids = [aws_security_group.web.id]
  
  # SSH
  key_name = var.key_name
  
  # Пользовательские данные
  user_data = templatefile("${path.module}/scripts/user-data.sh", {
    repo_url = var.repo_url
  })
  
  tags = merge(var.tags, {
    Role = "web-server"
  })
}
```

### Развертывание VPC

```hcl
module "vpc" {
  source = "github.com/v-grand/infra-network//modules/vpc-aws"
  
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  enable_nat_gateway   = true
  enable_dns_hostnames = true
  
  tags = var.tags
}
```

### Развертывание базы данных RDS

```hcl
module "database" {
  source = "github.com/v-grand/infra-core//modules/db"
  
  cloud = "aws"
  
  # Конфигурация экземпляра
  identifier     = "myapp-db"
  engine         = "postgres"
  engine_version = "15.3"
  instance_class = "db.t3.medium"
  
  # Хранилище
  allocated_storage     = 100
  max_allocated_storage = 500
  storage_encrypted     = true
  
  # База данных
  db_name  = "myapp"
  username = "admin"
  password = var.db_password  # Используйте менеджер секретов
  
  # Сеть
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  # Безопасность
  allowed_cidr_blocks = [var.vpc_cidr]
  
  # Резервное копирование
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "mon:04:00-mon:05:00"
  
  # Высокая доступность
  multi_az               = true
  deletion_protection    = true
  
  tags = var.tags
}
```

## 🔒 Конфигурация безопасности

### Группы безопасности

```hcl
# Группа безопасности веб-сервера
resource "aws_security_group" "web" {
  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = module.vpc.vpc_id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH (ограничено)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Исходящий трафик
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "web-server-sg"
  })
}
```

### Роли IAM

```hcl
# Роль экземпляра EC2
resource "aws_iam_role" "ec2_role" {
  name = "ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Присоединение политик
resource "aws_iam_role_policy_attachment" "ec2_s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
```

## 🔗 Примеры интеграции

### С infra-monitoring

```hcl
# Развертывание мониторинга
module "monitoring" {
  source = "github.com/v-grand/infra-monitoring//modules/prometheus"
  
  # Конфигурация, специфичная для AWS
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]
  
  instance_type = "t3.medium"
  
  # Цели сбора метрик
  scrape_targets = [
    module.web_server.instance_private_ip
  ]
}
```

### С infra-secrets

```hcl
# Хранение секретов в AWS Secrets Manager
module "secrets" {
  source = "github.com/v-grand/infra-secrets//modules/aws-secrets"
  
  secrets = {
    db_password = {
      secret_string           = var.db_password
      recovery_window_in_days = 30
    }
  }
}
```

## 📚 Лучшие практики

1. **Развертывание в нескольких зонах доступности (Multi-AZ)** - Развертывание в нескольких зонах доступности
2. **Шифрованное хранилище** - Включите шифрование для EBS и RDS
3. **Минимальные привилегии IAM** - Минимально необходимые разрешения
4. **Журналы потоков VPC (VPC Flow Logs)** - Включите для мониторинга сети
5. **Оповещения CloudWatch** - Настройте оповещения мониторинга
6. **Стратегия резервного копирования** - Регулярные автоматические снимки
7. **Оптимизация затрат** - Используйте зарезервированные экземпляры, точечные экземпляры
8. **Стратегия тегирования** - Последовательное тегирование ресурсов

## 🔧 Операции

### Подключение к экземпляру

```bash
# Получить IP экземпляра
terraform output instance_public_ip

# SSH подключение
ssh -i ~/.ssh/your-key.pem ec2-user@INSTANCE_IP

# Или используйте конфигурацию SSH
cp ops/ssh_config.example ~/.ssh/config
# Отредактируйте конфигурацию с вашим IP
ssh devml
```

### Резервное копирование и восстановление

```bash
# Создать снимок
aws ec2 create-snapshot \
  --volume-id vol-xxxxx \
  --description "Manual backup"

# Создать AMI
aws ec2 create-image \
  --instance-id i-xxxxx \
  --name "web-server-backup-$(date +%Y%m%d)"
```

## 📖 Документация

- [AWS Well-Architected](https://aws.amazon.com/architecture/well-architected/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS CLI Reference](https://docs.aws.amazon.com/cli/)

## 🔗 Связанные репозитории

- [infra-core](infra-core.md) - Переиспользуемые модули Terraform
- [infra-network](infra-network.md) - Конфигурация сети
- [infra-monitoring](infra-monitoring.md) - Настройка мониторинга
- [infra-secrets](infra-secrets.md) - Управление секретами
