# Witamy w Infra Docs

Witamy w pełnej dokumentacji ekosystemu infrastruktury **v-grand**. Ten zestaw repozytoriów zapewnia gotowe rozwiązanie produkcyjne dla wdrożeń wielochmurowych.

## 📚 Przegląd architektury

Ekosystem infrastruktury zbudowany jest na architekturze modułowej, gdzie każde repozytorium służy określonemu celowi:

```
┌─────────────────────┐
│    infra-docs       │  ← Dokumentacja i przykłady
└─────────────────────┘
          │
          ├─► infra-core       (Moduły Terraform wielokrotnego użytku)
          ├─► infra-template   (Szablon projektu)
          ├─► infra-ci         (Przepływy pracy CI/CD)
          │
          └─► Repozytoria aplikacji:
              ├─► infra-aws        (Infrastruktura AWS)
              ├─► infra-gcp        (Infrastruktura GCP)
              ├─► infra-network    (Konfiguracja sieci)
              ├─► infra-monitoring (Stos monitorowania)
              ├─► infra-secrets    (Zarządzanie sekretami)
              └─► infra-k8s        (Klastry Kubernetes)
```

## 🗂️ Przewodnik po repozytoriach

### Główne biblioteki

| Repozytorium | Przeznaczenie | Status |
|:------------|:-----------|:-------|
| **[infra-core](infra-core.md)** | Moduły Terraform wielokrotnego użytku (VM, VPC, DB, K8s, Tailscale) | ✅ Aktywny |
| **[infra-template](infra-template.md)** | Standaryzowany szablon dla nowych projektów | ✅ Aktywny |
| **[infra-ci](infra-ci.md)** | Przepływy pracy GitHub Actions wielokrotnego użytku dla CI/CD | ✅ Aktywny |
| **[infra-docs](https://github.com/v-grand/infra-docs)** | Strona dokumentacji (ta strona) | ✅ Aktywny |

### Infrastruktura chmurowa

| Repozytorium | Przeznaczenie | Obsługiwane chmury |
|:------------|:-----------|:----------------------|
| **[infra-aws](aws.md)** | Wdrażanie infrastruktury AWS | AWS |
| **[infra-gcp](gcp/index.md)** | Wdrażanie infrastruktury GCP | GCP |
| **[infra-network](infra-network.md)** | VPC, VPN, sieć mesh Tailscale | AWS, GCP |

### Usługi platformowe

| Repozytorium | Przeznaczenie | Kluczowe technologie |
|:------------|:-----------|:-------------------|
| **[infra-monitoring](infra-monitoring.md)** | Stos obserwowalności i logowania | Prometheus, Grafana, Loki |
| **[infra-secrets](infra-secrets.md)** | Scentralizowane zarządzanie sekretami | Vault, SOPS, GCP Secrets |
| **[infra-k8s](infra-k8s.md)** | Zarządzanie klastrami Kubernetes | GKE, EKS, K3s |

## 🚀 Szybki start

### Dla nowych projektów

1. **Sklonuj szablon:**
   ```bash
   git clone https://github.com/v-grand/infra-template.git my-new-project
   cd my-new-project
   ```

2. **Skonfiguruj środowisko:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edytuj terraform.tfvars z własnymi ustawieniami
   ```

3. **Wdróż:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Dla istniejących projektów

Wybierz odpowiednie repozytorium:

- **Wdrożenie AWS** → [infra-aws](aws.md)
- **Wdrożenie GCP** → [infra-gcp](gcp/index.md)
- **Kubernetes** → [infra-k8s](infra-k8s.md)
- **Monitorowanie** → [infra-monitoring](infra-monitoring.md)

## 📖 Struktura dokumentacji

- **[Moduły Infra Core](infra-core.md)** - Szczegółowa dokumentacja modułów
- **[Przykłady AWS](examples/aws-dev.md)** - Przykłady wdrożeń AWS
- **[Przewodniki GCP](gcp/index.md)** - Dokumentacja dla GCP
- **[Integracja Tailscale](tailscale.md)** - Konfiguracja sieci mesh
- **[Notatniki](../../notebooks/)** - Interaktywne przykłady i samouczki

## 🔗 Zasoby zewnętrzne

- [Dokumentacja Terraform](https://www.terraform.io/docs)
- [Dokumentacja GitHub Actions](https://docs.github.com/en/actions)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Google Cloud Architecture Center](https://cloud.google.com/architecture)

## 🤝 Wkład w projekt

Zapraszamy do współtworzenia projektu! Prosimy zapoznać się z wytycznymi dotyczącymi wkładu w poszczególnych repozytoriach.

## 📄 Licencja

Wszystkie repozytoria są objęte licencją MIT, chyba że zaznaczono inaczej.
