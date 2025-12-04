# Гайд по использованию инфраструктуры infra-*

Этот гайд демонстрирует, как использовать `infra-*` репозитории для развертывания простого веб-сервиса на AWS.

## Пример: Развертывание простого веб-сервиса

В этом примере мы развернем EC2 инстанс с веб-сервером Nginx, используя `infra-aws` и `infra-core` модули.

### 1. Структура проекта

Ваш проект должен иметь следующую структуру:

```
.
├── main.tf
└── variables.tf
```

### 2. `variables.tf`

Создайте файл `variables.tf` для определения переменных:

```terraform
variable "aws_region" {
  description = "AWS регион для развертывания"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Тип EC2 инстанса"
  type        = string
  default     = "t2.micro"
}
```

### 3. `main.tf`

Создайте файл `main.tf` для описания инфраструктуры:

```terraform
provider "aws" {
  region = var.aws_region
}

module "web_server" {
  source = "./infra-aws/modules/ec2" # Путь к модулю в субмодуле infra-aws

  instance_type = var.instance_type
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  key_name      = "default-key"

  tags = {
    Name = "My-Web-Server"
  }
}
```

### 4. Развертывание

1.  **Инициализация Terraform:**
    ```sh
    terraform init
    ```

2.  **Планирование:**
    ```sh
    terraform plan
    ```

3.  **Применение:**
    ```sh
    terraform apply
    ```

После выполнения этих команд Terraform создаст EC2 инстанс в вашем AWS аккаунте.
