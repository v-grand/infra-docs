# infra-k8s: Инфраструктура Kubernetes

**infra-k8s** обеспечивает полное развертывание и управление кластерами Kubernetes в GKE, EKS и K3s с интегрированными системными компонентами и мониторингом.

## 🎯 Назначение

Развертывание и управление кластерами Kubernetes:

- **GKE** - Кластеры Google Kubernetes Engine
- **EKS** - Amazon Elastic Kubernetes Service
- **K3s** - Легковесный Kubernetes для периферийных/локальных сред
- **Helm Charts** - Развертывание системных компонентов
- **GitOps** - Интеграция непрерывного развертывания

## 📁 Структура репозитория

```
infra-k8s/
├── modules/
│   ├── gke/                  # Google Kubernetes Engine
│   ├── eks/                  # AWS EKS
│   ├── k3s/                  # Развертывание K3s
│   └── addons/               # Helm-чарты и системные компоненты
│       ├── ingress/          # Входящий трафик NGINX/Traefik
│       ├── cert-manager/     # Управление сертификатами
│       ├── external-dns/     # Автоматизация DNS
│       └── prometheus-stack/ # Стек мониторинга
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars.example
│   │   └── backend.tf
│   ├── prod/
│   │   └── ...
│   └── k3s-example/          # Пример K3s на VM GCP
├── manifests/                # Манифесты Kubernetes
├── helm-values/              # Значения Helm-чартов
└── README.md
```

## ☸️ Модули кластера

### 1. GKE (Google Kubernetes Engine)

Развертывание управляемого Kubernetes в Google Cloud.

**Возможности:**
- Автомасштабируемые пулы узлов
- Региональные/зональные кластеры
- Идентификация рабочей нагрузки
- Бинарная авторизация
- Сетевые политики
- Приватные кластеры

**Пример:**
```hcl
module "gke_cluster" {
  source = "github.com/v-grand/infra-k8s//modules/gke"
  
  project_id = var.gcp_project_id
  region     = "us-central1"
  
  cluster_name    = "production-gke"
  kubernetes_version = "1.28"
  
  # Конфигурация сети
  network    = module.vpc.network_name
  subnetwork = module.vpc.subnet_names[0]
  
  # Включить приватный кластер
  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = "172.16.0.0/28"
  
  # Пулы узлов
  node_pools = [
    {
      name         = "general-pool"
      machine_type = "n2-standard-4"
      min_count    = 1
      max_count    = 10
      disk_size_gb = 100
      disk_type    = "pd-standard"
      
      auto_repair  = true
      auto_upgrade = true
      
      preemptible = false
    },
    {
      name         = "spot-pool"
      machine_type = "n2-standard-4"
      min_count    = 0
      max_count    = 20
      
      preemptible = true  # Использовать спотовые экземпляры
    }
  ]
  
  # Идентификация рабочей нагрузки
  enable_workload_identity = true
  
  # Безопасность
  enable_network_policy = true
  enable_pod_security_policy = true
  
  # Мониторинг
  enable_cloud_logging    = true
  enable_cloud_monitoring = true
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### 2. EKS (Amazon Elastic Kubernetes Service)

Развертывание управляемого Kubernetes в AWS.

**Возможности:**
- Управляемая плоскость управления
- Несколько групп узлов (по требованию + спотовые)
- Политики безопасности подов
- IRSA (роли IAM для учетных записей служб)
- Сеть VPC CNI
- Интеграция EBS/EFS

**Пример:**
```hcl
module "eks_cluster" {
  source = "github.com/v-grand/infra-k8s//modules/eks"
  
  cluster_name    = "production-eks"
  cluster_version = "1.28"
  
  # Конфигурация сети
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  # Плоскость управления
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  
  # Группы узлов
  node_groups = {
    general = {
      desired_capacity = 3
      max_capacity     = 10
      min_capacity     = 1
      
      instance_types = ["t3.large"]
      capacity_type  = "ON_DEMAND"
      
      disk_size = 100
      
      labels = {
        role = "general"
      }
      
      tags = {
        Environment = "production"
      }
    }
    
    spot = {
      desired_capacity = 2
      max_capacity     = 20
      min_capacity     = 0
      
      instance_types = ["t3.large", "t3a.large"]
      capacity_type  = "SPOT"
      
      labels = {
        role = "spot"
      }
    }
  }
  
  # Включить IRSA
  enable_irsa = true
  
  # Дополнения кластера
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### 3. K3s (Легковесный Kubernetes)

Развертывание K3s для периферийных устройств, IoT или локальной разработки.

**Возможности:**
- Минимальное потребление ресурсов
- Один бинарный файл
- Встроенная SQLite или внешняя БД
- Встроенный балансировщик нагрузки (Klipper)
- Включенный входящий трафик Traefik

**Пример:**
```hcl
module "k3s_cluster" {
  source = "github.com/v-grand/infra-k8s//modules/k3s"
  
  # Узлы сервера
  server_count = 3
  server_instance_type = "e2-medium"
  
  # Узлы агента
  agent_count = 5
  agent_instance_type = "e2-standard-2"
  
  # Сеть
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  # Хранилище
  datastore_endpoint = "postgres://user:pass@postgres.example.com:5432/k3s"
  
  # Опции
  disable_components = ["traefik"]  # Использовать NGINX вместо
  
  # TLS SANs
  tls_san = [
    "k3s.example.com",
    "10.0.0.100"
  ]
  
  tags = {
    Environment = "edge"
    ManagedBy   = "terraform"
  }
}
```

## 🔧 Системные дополнения

### 1. Контроллер входящего трафика

#### NGINX Ingress
```hcl
module "nginx_ingress" {
  source = "github.com/v-grand/infra-k8s//modules/addons/ingress"
  
  ingress_type = "nginx"
  namespace    = "ingress-nginx"
  
  # Значения Helm
  values = {
    controller = {
      replicaCount = 3
      
      service = {
        type = "LoadBalancer"
        annotations = {
          "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
        }
      }
      
      resources = {
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "256Mi"
        }
      }
    }
  }
}
```

#### Traefik Ingress
```hcl
module "traefik_ingress" {
  source = "github.com/v-grand/infra-k8s//modules/addons/ingress"
  
  ingress_type = "traefik"
  namespace    = "traefik"
  
  values = {
    deployment = {
      replicas = 3
    }
    
    service = {
      type = "LoadBalancer"
    }
    
    providers = {
      kubernetesCRD = {
        enabled = true
      }
    }
  }
}
```

### 2. Cert-Manager

Автоматическое управление TLS-сертификатами.

```hcl
module "cert_manager" {
  source = "github.com/v-grand/infra-k8s//modules/addons/cert-manager"
  
  namespace = "cert-manager"
  
  # Эмитенты Let's Encrypt
  letsencrypt_email = "admin@example.com"
  
  # Создать промежуточные и производственные эмитенты
  create_cluster_issuers = true
  
  values = {
    installCRDs = true
    
    resources = {
      requests = {
        cpu    = "10m"
        memory = "32Mi"
      }
    }
  }
}
```

**Пример ClusterIssuer:**
```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@example.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
```

### 3. External-DNS

Автоматическое управление записями DNS.

```hcl
module "external_dns" {
  source = "github.com/v-grand/infra-k8s//modules/addons/external-dns"
  
  namespace = "external-dns"
  
  # Конфигурация провайдера
  provider = "google"  # или "aws", "cloudflare"
  
  # Google Cloud DNS
  google_project = var.gcp_project_id
  
  # Фильтры доменов
  domain_filters = ["example.com", "*.example.com"]
  
  # Политика
  policy = "sync"  # или "upsert-only"
  
  values = {
    resources = {
      requests = {
        cpu    = "10m"
        memory = "32Mi"
      }
    }
  }
}
```

### 4. Kube Prometheus Stack

Комплексное решение для мониторинга.

```hcl
module "prometheus_stack" {
  source = "github.com/v-grand/infra-k8s//modules/addons/prometheus-stack"
  
  namespace = "monitoring"
  
  # Prometheus
  prometheus = {
    retention = "30d"
    storage_size = "50Gi"
    storage_class = "standard"
    
    resources = {
      requests = {
        cpu    = "500m"
        memory = "2Gi"
      }
      limits = {
        cpu    = "1000m"
        memory = "4Gi"
      }
    }
  }
  
  # Grafana
  grafana = {
    enabled = true
    admin_password = var.grafana_admin_password
    
    ingress = {
      enabled = true
      host    = "grafana.example.com"
      tls     = true
    }
  }
  
  # AlertManager
  alertmanager = {
    enabled = true
    
    config = {
      receivers = [
        {
          name = "slack"
          slack_configs = [
            {
              api_url = var.slack_webhook_url
              channel = "#alerts"
            }
          ]
        }
      ]
    }
  }
}
```

## 🚀 Быстрый старт

### Развертывание кластера GKE

```bash
# Клонируйте репозиторий
git clone https://github.com/v-grand/infra-k8s.git
cd infra-k8s/environments/prod

# Настройте
cp terraform.tfvars.example terraform.tfvars
# Отредактируйте terraform.tfvars

# Разверните
terraform init
terraform apply

# Получите kubeconfig
gcloud container clusters get-credentials production-gke \
  --region=us-central1 \
  --project=my-project
```

### Развертывание кластера EKS

```bash
cd infra-k8s/environments/prod

# Настройте
cp terraform.tfvars.example terraform.tfvars
# Отредактируйте terraform.tfvars

# Разверните
terraform init
terraform apply

# Получите kubeconfig
aws eks update-kubeconfig \
  --name production-eks \
  --region us-east-1
```

### Установка системных компонентов

```bash
# Установите NGINX Ingress
kubectl apply -f manifests/nginx-ingress.yaml

# Установите Cert-Manager
kubectl apply -f manifests/cert-manager.yaml

# Установите External-DNS
kubectl apply -f manifests/external-dns.yaml

# Установите Prometheus Stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -f helm-values/prometheus-stack.yaml \
  -n monitoring --create-namespace
```

## 📚 Лучшие практики

1. **Ограничения ресурсов** - Всегда устанавливайте запросы/ограничения ресурсов
2. **Бюджеты прерываний подов** - Обеспечьте высокую доступность
3. **Сетевые политики** - Внедрите сетевые политики с нулевым доверием
4. **RBAC** - Используйте доступ с наименьшими привилегиями
5. **Безопасность образов** - Сканируйте образы, используйте контроллеры допуска
6. **Управление секретами** - Используйте внешние операторы секретов
7. **Резервное копирование** - Регулярные резервные копии etcd/кластера
8. **Multi-AZ** - Развертывание в нескольких зонах доступности

## 🔗 Примеры интеграции

### С infra-monitoring

```hcl
# Развертывание мониторинга в K8s
module "monitoring" {
  source = "github.com/v-grand/infra-monitoring//modules/prometheus"
  
  deploy_to_k8s = true
  k8s_namespace = "monitoring"
  
  # Использовать обнаружение служб K8s
  prometheus_config = templatefile("prometheus-k8s.yaml", {
    cluster_name = module.gke_cluster.cluster_name
  })
}
```

### С infra-secrets

```hcl
# Интеграция Vault с K8s
module "vault_k8s" {
  source = "github.com/v-grand/infra-secrets//modules/vault-k8s"
  
  vault_address = "https://vault.example.com"
  
  # Создать бэкэнд аутентификации Kubernetes
  k8s_host = module.gke_cluster.endpoint
  k8s_ca_cert = module.gke_cluster.ca_certificate
}
```

## 📖 Документация

- [Документация Kubernetes](https://kubernetes.io/docs/)
- [Документация GKE](https://cloud.google.com/kubernetes-engine/docs)
- [Документация EKS](https://docs.aws.amazon.com/eks/)
- [Документация K3s](https://docs.k3s.io/)

## 🔗 Связанные репозитории

- [infra-core](infra-core.md) - Модули инфраструктуры
- [infra-network](infra-network.md) - Конфигурация сети
- [infra-monitoring](infra-monitoring.md) - Интеграция мониторинга
- [infra-secrets](infra-secrets.md) - Управление секретами
