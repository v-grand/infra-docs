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

### 4. Развертывание с помощью Terraform

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

---

## Продвинутое использование: `infra-deployer` CLI

Для упрощения и автоматизации процесса развертывания, особенно в CI/CD пайплайнах, вы можете использовать `infra-deployer`. Это утилита-обертка, которая стандартизирует запуск Terraform.

### Установка

*Предполагается, что `infra-deployer` установлен и доступен в вашем PATH.*

### Использование

`infra-deployer` упрощает процесс до одной команды. Он автоматически находит нужную конфигурацию, инициализирует Terraform и применяет изменения.

**Команда для развертывания:**

```sh
infra-deployer apply --env=dev --app=web-server
```

**Параметры:**

*   `--env`: Указывает на окружение (например, `dev`, `staging`, `prod`). Это позволяет `infra-deployer` использовать правильные файлы переменных (например, `dev.tfvars`).
*   `--app`: Указывает на конкретное приложение или стек для развертывания.

`infra-deployer` выполнит те же шаги (`init`, `plan`, `apply`), но с дополнительной логикой для выбора нужного workspace и переменных, что делает процесс более надежным и предсказуемым.
