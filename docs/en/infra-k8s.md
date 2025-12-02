# infra-k8s: Kubernetes Infrastructure

**infra-k8s** provides complete Kubernetes cluster deployment and management across GKE, EKS, and K3s with integrated system components and monitoring.

## 🎯 Purpose

Deploy and manage Kubernetes clusters:

- **GKE** - Google Kubernetes Engine clusters
- **EKS** - Amazon Elastic Kubernetes Service
- **K3s** - Lightweight Kubernetes for edge/local
- **Helm Charts** - System component deployment
- **GitOps** - Continuous deployment integration

## 📁 Repository Structure

```
infra-k8s/
├── modules/
│   ├── gke/                  # Google Kubernetes Engine
│   ├── eks/                  # AWS EKS
│   ├── k3s/                  # K3s deployment
│   └── addons/               # Helm charts & system components
│       ├── ingress/          # NGINX/Traefik ingress
│       ├── cert-manager/     # Certificate management
│       ├── external-dns/     # DNS automation
│       └── prometheus-stack/ # Monitoring stack
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars.example
│   │   └── backend.tf
│   ├── prod/
│   │   └── ...
│   └── k3s-example/          # K3s on GCP VM example
├── manifests/                # Kubernetes manifests
├── helm-values/              # Helm chart values
└── README.md
```

## ☸️ Cluster Modules

### 1. GKE (Google Kubernetes Engine)

Deploy managed Kubernetes on Google Cloud.

**Features:**
- Auto-scaling node pools
- Regional/zonal clusters
- Workload identity
- Binary authorization
- Network policies
- Private clusters

**Example:**
```hcl
module "gke_cluster" {
  source = "github.com/v-grand/infra-k8s//modules/gke"
  
  project_id = var.gcp_project_id
  region     = "us-central1"
  
  cluster_name    = "production-gke"
  kubernetes_version = "1.28"
  
  # Network configuration
  network    = module.vpc.network_name
  subnetwork = module.vpc.subnet_names[0]
  
  # Enable private cluster
  enable_private_nodes    = true
  enable_private_endpoint = false
  master_ipv4_cidr_block  = "172.16.0.0/28"
  
  # Node pools
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
      
      preemptible = true  # Use spot instances
    }
  ]
  
  # Workload Identity
  enable_workload_identity = true
  
  # Security
  enable_network_policy = true
  enable_pod_security_policy = true
  
  # Monitoring
  enable_cloud_logging    = true
  enable_cloud_monitoring = true
  
  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### 2. EKS (Amazon Elastic Kubernetes Service)

Deploy managed Kubernetes on AWS.

**Features:**
- Managed control plane
- Multiple node groups (on-demand + spot)
- Pod security policies
- IRSA (IAM Roles for Service Accounts)
- VPC CNI networking
- EBS/EFS integration

**Example:**
```hcl
module "eks_cluster" {
  source = "github.com/v-grand/infra-k8s//modules/eks"
  
  cluster_name    = "production-eks"
  cluster_version = "1.28"
  
  # Network configuration
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  # Control plane
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  
  # Node groups
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
  
  # Enable IRSA
  enable_irsa = true
  
  # Cluster addons
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

### 3. K3s (Lightweight Kubernetes)

Deploy K3s for edge, IoT, or local development.

**Features:**
- Minimal resource footprint
- Single binary
- Embedded SQLite or external DB
- Built-in load balancer (Klipper)
- Traefik ingress included

**Example:**
```hcl
module "k3s_cluster" {
  source = "github.com/v-grand/infra-k8s//modules/k3s"
  
  # Server nodes
  server_count = 3
  server_instance_type = "e2-medium"
  
  # Agent nodes
  agent_count = 5
  agent_instance_type = "e2-standard-2"
  
  # Network
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  
  # Storage
  datastore_endpoint = "postgres://user:pass@postgres.example.com:5432/k3s"
  
  # Options
  disable_components = ["traefik"]  # Use NGINX instead
  
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

## 🔧 System Addons

### 1. Ingress Controller

#### NGINX Ingress
```hcl
module "nginx_ingress" {
  source = "github.com/v-grand/infra-k8s//modules/addons/ingress"
  
  ingress_type = "nginx"
  namespace    = "ingress-nginx"
  
  # Helm values
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

Automatic TLS certificate management.

```hcl
module "cert_manager" {
  source = "github.com/v-grand/infra-k8s//modules/addons/cert-manager"
  
  namespace = "cert-manager"
  
  # Let's Encrypt issuers
  letsencrypt_email = "admin@example.com"
  
  # Create staging and production issuers
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

**ClusterIssuer Example:**
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

Automatic DNS record management.

```hcl
module "external_dns" {
  source = "github.com/v-grand/infra-k8s//modules/addons/external-dns"
  
  namespace = "external-dns"
  
  # Provider configuration
  provider = "google"  # or "aws", "cloudflare"
  
  # Google Cloud DNS
  google_project = var.gcp_project_id
  
  # Domain filters
  domain_filters = ["example.com", "*.example.com"]
  
  # Policy
  policy = "sync"  # or "upsert-only"
  
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

Complete monitoring solution.

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

## 🚀 Quick Start

### Deploy GKE Cluster

```bash
# Clone repository
git clone https://github.com/v-grand/infra-k8s.git
cd infra-k8s/environments/prod

# Configure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

# Deploy
terraform init
terraform apply

# Get kubeconfig
gcloud container clusters get-credentials production-gke \
  --region=us-central1 \
  --project=my-project
```

### Deploy EKS Cluster

```bash
cd infra-k8s/environments/prod

# Configure
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars

# Deploy
terraform init
terraform apply

# Get kubeconfig
aws eks update-kubeconfig \
  --name production-eks \
  --region us-east-1
```

### Install System Components

```bash
# Install NGINX Ingress
kubectl apply -f manifests/nginx-ingress.yaml

# Install Cert-Manager
kubectl apply -f manifests/cert-manager.yaml

# Install External-DNS
kubectl apply -f manifests/external-dns.yaml

# Install Prometheus Stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -f helm-values/prometheus-stack.yaml \
  -n monitoring --create-namespace
```

## 📚 Best Practices

1. **Resource Limits** - Always set resource requests/limits
2. **Pod Disruption Budgets** - Ensure high availability
3. **Network Policies** - Implement zero-trust networking
4. **RBAC** - Use least privilege access
5. **Image Security** - Scan images, use admission controllers
6. **Secrets Management** - Use external secrets operators
7. **Backup** - Regular etcd/cluster backups
8. **Multi-AZ** - Deploy across availabil zones

## 🔗 Integration Examples

### With infra-monitoring

```hcl
# Deploy monitoring to K8s
module "monitoring" {
  source = "github.com/v-grand/infra-monitoring//modules/prometheus"
  
  deploy_to_k8s = true
  k8s_namespace = "monitoring"
  
  # Use K8s service discovery
  prometheus_config = templatefile("prometheus-k8s.yaml", {
    cluster_name = module.gke_cluster.cluster_name
  })
}
```

### With infra-secrets

```hcl
# Integrate Vault with K8s
module "vault_k8s" {
  source = "github.com/v-grand/infra-secrets//modules/vault-k8s"
  
  vault_address = "https://vault.example.com"
  
  # Create Kubernetes auth backend
  k8s_host = module.gke_cluster.endpoint
  k8s_ca_cert = module.gke_cluster.ca_certificate
}
```

## 📖 Documentation

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [EKS Documentation](https://docs.aws.amazon.com/eks/)
- [K3s Documentation](https://docs.k3s.io/)

## 🔗 Related Repositories

- [infra-core](infra-core.md) - Infrastructure modules
- [infra-network](infra-network.md) - Network configuration
- [infra-monitoring](infra-monitoring.md) - Monitoring integration
- [infra-secrets](infra-secrets.md) - Secrets management
