# Пример среды разработки AWS

Этот пример демонстрирует, как настроить полную среду разработки на AWS с использованием модулей `infra-core`.

Он включает:
- VPC с подсетями
- Экземпляр EC2 (VM)
- Базу данных RDS MySQL
- Интеграцию Tailscale для безопасного доступа

## Конфигурация (`main.tf`)

```hcl
# main.tf для примера aws-dev

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../../modules/vpc"

  provider          = "aws"
  cidr_block        = "10.0.0.0/16"
  subnet_cidr_block = "10.0.1.0/24"
  tags = {
    Name = "aws-dev-vpc"
  }
}

module "vm" {
  source = "../../modules/vm"

  provider      = "aws"
  ami           = "ami-0c55b159cbfafe1f0" # us-east-1
  instance_type = "t2.micro"
  tags = {
    Name = "aws-dev-vm"
  }
}

module "db" {
  source = "../../modules/db"

  provider          = "aws"
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t2.micro"
  db_name           = "awsdevdb"
  username          = "user"
  password          = "password" # Замените на безопасный пароль
  tags = {
    Name = "aws-dev-db"
  }
}

module "tailscale" {
  source = "../../modules/tailscale"

  instance_id      = module.vm.instance_id
  auth_key         = "your-tailscale-auth-key" # Замените на ваш ключ аутентификации
  ssh_user         = "ec2-user"
  private_key_path = "~/.ssh/id_rsa" # Замените на путь к вашему приватному ключу
  host             = module.vm.public_ip
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vm_id" {
  value = module.vm.instance_id
}

output "db_id" {
  value = module.db.db_instance_id
}
```
