# infra-network: Сетевая инфраструктура

**infra-network** предоставляет комплексные модули сетевой инфраструктуры, включая конфигурацию VPC, настройку VPN и ячеистую сеть Tailscale для различных облачных провайдеров.

## 🎯 Назначение

Этот репозиторий управляет сетевой инфраструктурой:

- **Конфигурация VPC** - Виртуальные частные облака для AWS и GCP
- **Настройка VPN** - Конфигурации VPN типа "сайт-сайт" и клиентского VPN
- **Интеграция Tailscale** - Ячеистая сеть без настройки
- **Мультиоблачная сеть** - Единая сеть для разных облаков

## 📁 Структура репозитория

```
infra-network/
├── modules/
│   ├── vpc-aws/              # Модуль AWS VPC
│   ├── vpc-gcp/              # Модуль GCP VPC
│   ├── vpn/                  # Конфигурации VPN
│   └── tailscale/            # Ячеистая сеть Tailscale
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars.example
│   │   └── backend.tf
│   └── prod/
│       └── ...
├── .github/
│   └── workflows/
│       └── deploy.yml        # Конвейер CI/CD
└── README.md
```

## 🌐 Модули

### 1. Модуль VPC (AWS)

Создание AWS Virtual Private Clouds с подсетями, таблицами маршрутизации и интернет-шлюзами.

**Пример использования:**
```hcl
module "vpc_aws" {
  source = "github.com/v-grand/infra-network//modules/vpc-aws"
  
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  
  enable_nat_gateway = true
  enable_dns_hostnames = true
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### 2. Модуль VPC (GCP)

Создание GCP Virtual Private Clouds с пользовательскими подсетями и правилами брандмауэра.

**Пример использования:**
```hcl
module "vpc_gcp" {
  source = "github.com/v-grand/infra-network//modules/vpc-gcp"
  
  project_id   = "my-gcp-project"
  network_name = "main-vpc"
  
  subnets = [
    {
      subnet_name   = "subnet-01"
      subnet_ip     = "10.10.10.0/24"
      subnet_region = "us-central1"
    },
    {
      subnet_name   = "subnet-02"
      subnet_ip     = "10.10.20.0/24"
      subnet_region = "us-east1"
    }
  ]
  
  firewall_rules = [
    {
      name        = "allow-ssh"
      direction   = "INGRESS"
      ranges      = ["0.0.0.0/0"]
      allow_ports = ["22"]
      protocol    = "tcp"
    }
  ]
}
```

### 3. Модуль VPN

Настройка VPN-соединений типа "сайт-сайт" между облаками.

**Пример использования:**
```hcl
module "vpn" {
  source = "github.com/v-grand/infra-network//modules/vpn"
  
  vpn_type = "site-to-site"
  
  local_network  = "10.0.0.0/16"
  remote_network = "10.10.0.0/16"
  
  peer_ip_address = "203.0.113.1"
  shared_secret   = var.vpn_shared_secret
  
  tags = {
    Environment = "production"
  }
}
```

### 4. Модуль Tailscale

Развертывание Tailscale для ячеистой сети без настройки.

**Пример использования:**
```hcl
module "tailscale" {
  source = "github.com/v-grand/infra-network//modules/tailscale"
  
  auth_key    = var.tailscale_auth_key
  hostname    = "app-server-01"
  advertise_routes = ["10.0.0.0/16"]
  accept_routes    = true
  
  enable_ssh = true
}
```

## 🚀 Быстрый старт

### 1. Клонируйте репозиторий

```bash
git clone https://github.com/v-grand/infra-network.git
cd infra-network
```

### 2. Настройте окружение

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
```

Отредактируйте `terraform.tfvars`:
```hcl
# Конфигурация AWS
aws_region = "us-east-1"
vpc_cidr   = "10.0.0.0/16"

# Конфигурация GCP
gcp_project = "my-project-id"
gcp_region  = "us-central1"

# Tailscale
tailscale_auth_key = "tskey-xxxxxxxxxxxxx"
```

### 3. Разверните

```bash
terraform init
terraform plan
terraform apply
```

## 🔐 Конфигурация безопасности

### Правила брандмауэра

**Группы безопасности AWS:**
```hcl
resource "aws_security_group" "web" {
  name        = "web-server"
  description = "Allow HTTP/HTTPS inbound traffic"
  vpc_id      = module.vpc_aws.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**Правила брандмауэра GCP:**
```hcl
resource "google_compute_firewall" "web" {
  name    = "allow-web"
  network = module.vpc_gcp.network_name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}
```

## 📊 Сетевая архитектура

### Мультиоблачный дизайн

```
┌─────────────────────────────────────────────────┐
│             Ячеистая сеть Tailscale             │
│                 (10.100.0.0/16)                 │
└─────────────────────────────────────────────────┘
                    ▲         ▲
                    │         │
         ┌──────────┘         └──────────┐
         │                                │
    ┌────┴─────┐                    ┌────┴─────┐
    │   AWS    │                    │   GCP    │
    │   VPC    │◄───── VPN ────────►│   VPC    │
    │10.0.0.0/16                    │10.10.0.0/16
    └──────────┘                    └──────────┘
```

## 🔗 Примеры интеграции

### С infra-aws

```hcl
# infra-aws/main.tf
module "network" {
  source = "github.com/v-grand/infra-network//modules/vpc-aws"
  
  vpc_cidr = var.vpc_cidr
  # ... конфигурация
}

module "app_server" {
  source = "github.com/v-grand/infra-core//modules/vm"
  
  subnet_id         = module.network.public_subnet_ids[0]
  security_group_id = module.network.default_security_group_id
  # ... конфигурация
}
```

### С infra-gcp

```hcl
# infra-gcp/main.tf
module "network" {
  source = "github.com/v-grand/infra-network//modules/vpc-gcp"
  
  project_id = var.gcp_project_id
  # ... конфигурация
}

module "app_server" {
  source = "github.com/v-grand/infra-core//modules/vm"
  
  network    = module.network.network_name
  subnetwork = module.network.subnet_names[0]
  # ... конфигурация
}
```

## 📚 Лучшие практики

1. **Планирование CIDR** - Тщательно планируйте диапазоны IP, чтобы избежать конфликтов
2. **Сегментация подсетей** - Разделяйте публичные/приватные/данные подсети
3. **NAT Gateways** - Используйте NAT для доступа к интернету из приватных подсетей
4. **Шифрование VPN** - Всегда используйте сильное шифрование для VPN
5. **ACL Tailscale** - Правильно настраивайте списки контроля доступа
6. **Transit Gateways** - Для сложных мульти-VPC архитектур

## 🛠️ Переменные

### Общие переменные

| Переменная | Описание | По умолчанию |
|:---------|:------------|:--------|
| `vpc_cidr` | Блок CIDR для VPC | `10.0.0.0/16` |
| `availability_zones` | Список зон доступности | `[]` |
| `enable_nat_gateway` | Включить NAT-шлюз | `true` |
| `enable_vpn_gateway` | Включить VPN-шлюз | `false` |
| `tailscale_auth_key` | Ключ аутентификации Tailscale | `""` |

## 📖 Документация

- [Шаблоны проектирования VPC](https://aws.amazon.com/vpc/)
- [Сеть GCP](https://cloud.google.com/vpc/docs)
- [Документация Tailscale](https://tailscale.com/kb/)

## 🔗 Связанные репозитории

- [infra-core](infra-core.md) - Переиспользуемые модули Terraform
- [infra-aws](aws.md) - Инфраструктура AWS
- [infra-gcp](gcp/index.md) - Инфраструктура GCP
- [infra-monitoring](https://github.com/v-grand/infra-monitoring) - Подключение мониторинга через сети
