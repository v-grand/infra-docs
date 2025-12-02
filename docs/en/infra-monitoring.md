# infra-monitoring: Observability Stack

**infra-monitoring** provides a complete observability solution with metrics collection, logging, and visualization for cloud infrastructure.

## 🎯 Purpose

Deploy and manage a comprehensive monitoring stack:

- **Prometheus** - Metrics collection and alerting
- **Grafana** - Visualization and dashboards
- **Loki** - Log aggregation and querying
- **Exporters** - Node, cloud, and application metrics

## 📁 Repository Structure

```
infra-monitoring/
├── modules/
│   ├── prometheus/         # Prometheus setup
│   ├── grafana/            # Grafana with dashboards
│   ├── loki/               # Loki log aggregation
│   └── exporters/          # Various exporters
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars.example
│   │   └── backend.tf
│   └── prod/
│       └── ...
├── dashboards/             # Pre-configured Grafana dashboards
├── alert_rules.yml         # Prometheus alerting rules
├── docker-compose.yml      # Local development setup
└── README.md
```

## 📊 Components

### 1. Prometheus

Time-series metrics database with powerful querying and alerting.

**Features:**
- Multi-dimensional metrics
- PromQL query language
- Alert manager integration
- Service discovery
- Long-term storage

**Example Configuration:**
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

Visualization and analytics platform.

**Features:**
- Rich dashboards
- Multiple data sources
- Alerting
- User management
- Dashboard versioning

**Pre-configured Dashboards:**
- **Infrastructure Overview** - CPU, Memory, Disk, Network
- **Application Metrics** - Request rates, latencies, errors
- **Kubernetes Monitoring** - Pod/node metrics
- **Database Performance** - Query performance, connections
- **Cloud Costs** - Cost tracking and optimization

### 3. Loki

Horizontally-scalable log aggregation system.

**Features:**
- Label-based indexing
- LogQL query language
- Integration with Grafana
- Low cost storage
- Promtail agent

**Example Configuration:**
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

### 4. Exporters

Collect metrics from various sources.

**Available Exporters:**
- **Node Exporter** - System metrics (CPU, memory, disk)
- **cAdvisor** - Container metrics
- **Blackbox Exporter** - Endpoint monitoring
- **Cloud Exporters** - AWS CloudWatch, GCP Monitoring
- **Database Exporters** - PostgreSQL, MySQL, Redis

## 🚀 Quick Start

### Local Development with Docker Compose

```bash
# Clone repository
git clone https://github.com/v-grand/infra-monitoring.git
cd infra-monitoring

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Start stack
docker-compose up -d

# Access services
# Grafana: http://localhost:3000 (admin/admin)
# Prometheus: http://localhost:9090
# Loki: http://localhost:3100
```

### Production Deployment with Terraform

```bash
cd environments/prod
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars
terraform init
terraform plan
terraform apply
```

## 📈 Grafana Dashboards

### 1. Infrastructure Overview Dashboard

Monitors overall infrastructure health:
- CPU usage across all instances
- Memory utilization
- Disk I/O and capacity
- Network traffic
- System load averages

**Import ID:** `1860` (Node Exporter Full)

### 2. Application Performance Dashboard

Tracks application metrics:
- Request rate and latency
- Error rates (4xx, 5xx)
- Database query performance
- Cache hit ratios
- Queue depths

### 3. Kubernetes Dashboard

Kubernetes cluster monitoring:
- Node status and resources
- Pod health and restarts
- Deployment status
- Resource quotas
- Persistent volume usage

**Import ID:** `15759` (Kubernetes cluster monitoring)

### 4. Cost Monitoring Dashboard

Track cloud spending:
- Daily/monthly costs by service
- Resource utilization vs. cost
- Cost predictions
- Budget alerts

## 🔔 Alerting Rules

### Example Alert Rules

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
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "CPU usage is above 80% (current value: {{ $value }}%)"

      - alert: HighMemoryUsage
        expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 90
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"
          description: "Memory usage is above 90% (current value: {{ $value }}%)"

      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Low disk space on {{ $labels.instance }}"
          description: "Disk space is below 10% (current value: {{ $value }}%)"

      - alert: ServiceDown
        expr: up == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} is down"
          description: "{{ $labels.instance }} has been down for more than 2 minutes"
```

### AlertManager Configuration

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

## 🔗 Integration Examples

### With infra-aws

```hcl
# Deploy monitoring to AWS
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

### With infra-k8s

```hcl
# Deploy to Kubernetes
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

### With infra-gcp

```hcl
# Integrate with GCP monitoring
module "gcp_monitoring" {
  source = "github.com/v-grand/infra-monitoring//modules/gcp-exporter"
  
  project_id = var.gcp_project_id
  
  export_metrics = [
    "compute.googleapis.com/instance/cpu/utilization",
    "compute.googleapis.com/instance/network/received_bytes_count"
  ]
}
```

## 🛡️ Security Configuration

### Authentication

```hcl
# Grafana authentication
environment = {
  GF_AUTH_GENERIC_OAUTH_ENABLED      = "true"
  GF_AUTH_GENERIC_OAUTH_CLIENT_ID    = var.oauth_client_id
  GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET = var.oauth_client_secret
  GF_AUTH_GENERIC_OAUTH_SCOPES       = "openid email profile"
}
```

### TLS/SSL

```yaml
# Prometheus with TLS
tls_config:
  cert_file: /etc/prometheus/certs/prometheus.crt
  key_file: /etc/prometheus/certs/prometheus.key
  client_ca_file: /etc/prometheus/certs/ca.crt
```

## 📚 Best Practices

1. **Retention Policies** - Configure appropriate data retention
2. **High Availability** - Deploy redundant Prometheus instances
3. **Storage** - Use persistent volumes for data
4. **Scrape Intervals** - Balance between granularity and load
5. **Label Cardinality** - Avoid high-cardinality labels
6. **Dashboard Organization** - Use folders and tags

## 📖 Documentation

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)

## 🔗 Related Repositories

- [infra-core](infra-core.md) - Infrastructure modules
- [infra-k8s](https://github.com/v-grand/infra-k8s) - Kubernetes integration
- [infra-network](infra-network.md) - Network configuration
