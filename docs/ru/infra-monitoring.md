# infra-monitoring: Стек наблюдаемости

**infra-monitoring** предоставляет комплексное решение для наблюдаемости сбора метрик, логирования и визуализации для облачной инфраструктуры.

## 🎯 Назначение

Развертывание и управление комплексным стеком мониторинга:

- **Prometheus** - Сбор метрик и оповещения
- **Grafana** - Визуализация и дашборды
- **Loki** - Агрегация и запрос логов
- **Экспортеры** - Метрики узлов, облака и приложений

## 📁 Структура репозитория

```
infra-monitoring/
├── modules/
│   ├── prometheus/         # Настройка Prometheus
│   ├── grafana/            # Grafana с дашбордами
│   ├── loki/               # Агрегация логов Loki
│   └── exporters/          # Различные экспортеры
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars.example
│   │   └── backend.tf
│   └── prod/
│       └── ...
├── dashboards/             # Предварительно настроенные дашборды Grafana
├── alert_rules.yml         # Правила оповещений Prometheus
├── docker-compose.yml      # Настройка для локальной разработки
└── README.md
```

## 📊 Компоненты

### 1. Prometheus

База данных временных рядов метрик с мощными возможностями запросов и оповещений.

**Возможности:**
- Многомерные метрики
- Язык запросов PromQL
- Интеграция с Alertmanager
- Обнаружение сервисов
- Долгосрочное хранение

**Пример конфигурации:**
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'gcp-monitoring'
    static_configs:
      - targets: ['gcp-exporter:9090']
```

### 2. Grafana

Платформа для визуализации и аналитики.

**Возможности:**
- Богатые дашборды
- Несколько источников данных
- Оповещения
- Управление пользователями
- Версионирование дашбордов

**Предварительно настроенные дашборды:**
- **Обзор инфраструктуры** - CPU, память, диск, сеть
- **Метрики приложений** - Скорость запросов, задержки, ошибки
- **Мониторинг Kubernetes** - Метрики подов/узлов
- **Производительность базы данных** - Производительность запросов, соединения
- **Облачные расходы** - Отслеживание и оптимизация затрат

### 3. Loki

Горизонтально масштабируемая система агрегации логов.

**Возможности:**
- Индексирование на основе меток
- Язык запросов LogQL
- Интеграция с Grafana
- Низкозатратное хранение
- Агент Promtail

**Пример конфигурации:**
```yaml
# loki-config.yaml
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
  chunk_idle_period: 5m
  chunk_retain_period: 30s

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 168h
```

### 4. Экспортеры

Сбор метрик из различных источников.

**Доступные экспортеры:**
- **Node Exporter** - Системные метрики (CPU, память, диск)
- **cAdvisor** - Метрики контейнеров
- **Blackbox Exporter** - Мониторинг конечных точек
- **Облачные экспортеры** - AWS CloudWatch, GCP Monitoring
- **Экспортеры баз данных** - PostgreSQL, MySQL, Redis

## 🚀 Быстрый старт

### Локальная разработка с Docker Compose

```bash
# Клонируйте репозиторий
git clone https://github.com/v-grand/infra-monitoring.git
cd infra-monitoring

# Настройте окружение
cp .env.example .env
# Отредактируйте .env с вашими настройками

# Запустите стек
docker-compose up -d

# Доступ к сервисам
# Grafana: http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090
# Loki: http://localhost:3100
```

### Развертывание в production с Terraform

```bash
cd environments/prod
cp terraform.tfvars.example terraform.tfvars

# Отредактируйте terraform.tfvars
terraform init
terraform plan
terraform apply
```

## 📈 Дашборды Grafana

### 1. Дашборд обзора инфраструктуры

Мониторинг общего состояния инфраструктуры:
- Использование CPU на всех экземплярах
- Использование памяти
- Ввод/вывод диска и емкость
- Сетевой трафик
- Средняя загрузка системы

**ID импорта:** `1860` (Node Exporter Full)

### 2. Дашборд производительности приложений

Отслеживание метрик приложений:
- Скорость запросов и задержка
- Частота ошибок (4xx, 5xx)
- Производительность запросов к базе данных
- Коэффициенты попадания в кэш
- Глубина очередей

### 3. Дашборд Kubernetes

Мониторинг кластера Kubernetes:
- Состояние и ресурсы узлов
- Здоровье подов и перезапуски
- Состояние развертывания
- Квоты ресурсов
- Использование постоянных томов

**ID импорта:** `15759` (Мониторинг кластера Kubernetes)

### 4. Дашборд мониторинга затрат

Отслеживание облачных расходов:
- Ежедневные/ежемесячные расходы по сервисам
- Использование ресурсов по сравнению с затратами
- Прогнозы затрат
- Оповещения о бюджете

## 🔔 Правила оповещений

### Пример правил оповещений

```yaml
# alert_rules.yml
groups:
  - name: infrastructure_alerts
    interval: 30s
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Высокая загрузка CPU на {{ $labels.instance }}"
          description: "Загрузка CPU превышает 80% (текущее значение: {{ $value }}%)"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Высокое использование памяти на {{ $labels.instance }}"
          description: "Использование памяти превышает 90% (текущее значение: {{ $value }}%)"

      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Мало места на диске на {{ $labels.instance }}"
          description: "Место на диске меньше 10% (текущее значение: {{ $value }}%)"

      - alert: ServiceDown
        expr: up == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Сервис {{ $labels.job }} не работает"
          description: "{{ $labels.instance }} не работает более 2 минут"
```

### Конфигурация AlertManager

```yaml
# alertmanager.yml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'
  routes:
    - match:
        severity: critical
      receiver: 'critical-alerts'
    - match:
        severity: warning
      receiver: 'warning-alerts'

receivers:
  - name: 'default'
    slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK_URL'
        channel: '#alerts'
        
  - name: 'critical-alerts'
    slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK_URL'
        channel: '#critical-alerts'
    pagerduty_configs:
      - service_key: 'YOUR_PAGERDUTY_KEY'
        
  - name: 'warning-alerts'
    slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK_URL'
        channel: '#warnings'
```

## 🔗 Примеры интеграции

### С infra-aws

```hcl
# Развертывание мониторинга в AWS
module "monitoring" {
  source = "github.com/v-grand/infra-monitoring//modules/prometheus"
  
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]
  
  instance_type = "t3.medium"
  
  scrape_targets = [
    "http://app-server-1:9100",
    "http://app-server-2:9100"
  ]
}
```

### С infra-k8s

```hcl
# Развертывание в Kubernetes
module "prometheus_helm" {
  source = "github.com/v-grand/infra-monitoring//modules/prometheus"
  
  deploy_to_k8s = true
  namespace      = "monitoring"
  
  storage_class = "standard"
  storage_size  = "50Gi"
  
  grafana_enabled     = true
  alertmanager_enabled = true
}
```

### С infra-gcp

```hcl
# Интеграция с мониторингом GCP
module "gcp_monitoring" {
  source = "github.com/v-grand/infra-monitoring//modules/gcp-exporter"
  
  project_id = var.gcp_project_id
  
  export_metrics = [
    "compute.googleapis.com/instance/cpu/utilization",
    "compute.googleapis.com/instance/network/received_bytes_count"
  ]
}
```

## 🛡️ Конфигурация безопасности

### Аутентификация

```hcl
# Аутентификация Grafana
environment = {
  GF_AUTH_GENERIC_OAUTH_ENABLED      = "true"
  GF_AUTH_GENERIC_OAUTH_CLIENT_ID    = var.oauth_client_id
  GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET = var.oauth_client_secret
  GF_AUTH_GENERIC_OAUTH_SCOPES       = "openid email profile"
}
```

### TLS/SSL

```yaml
# Prometheus с TLS
tls_config:
  cert_file: /etc/prometheus/certs/prometheus.crt
  key_file: /etc/prometheus/certs/prometheus.key
  client_ca_file: /etc/prometheus/certs/ca.crt
```

## 📚 Лучшие практики

1. **Политики хранения** - Настройте соответствующие политики хранения данных
2. **Высокая доступность** - Разверните избыточные экземпляры Prometheus
3. **Хранилище** - Используйте постоянные тома для данных
4. **Интервалы сбора** - Баланс между детализацией и нагрузкой
5. **Кардинальность меток** - Избегайте меток с высокой кардинальностью
6. **Организация дашбордов** - Используйте папки и теги

## 📖 Документация

- [Документация Prometheus](https://prometheus.io/docs/)
- [Документация Grafana](https://grafana.com/docs/)
- [Документация Loki](https://grafana.com/docs/loki/)

## 🔗 Связанные репозитории

- [infra-core](infra-core.md) - Модули инфраструктуры
- [infra-k8s](https://github.com/v-grand/infra-k8s) - Интеграция Kubernetes
- [infra-network](infra-network.md) - Конфигурация сети
