# Szybki start: infra-ci

Dokumentacja jest w trakcie tłumaczenia.

Zobacz [wersję angielską](../en/infra-ci.md) dla pełnej dokumentacji.

## Krótki opis

**infra-ci** - scentralizowane repozytorium z ponownie używanymi przepływami pracy GitHub Actions do automatyzacji procesów CI/CD.

## Główne możliwości

- Ponownie używane przepływy pracy Terraform
- Automatyczna walidacja kodu
- Integracja z SOPS dla sekretów
- Obsługa wdrożeń multi-cloud

## Szybkie użycie

```yaml
# .github/workflows/deploy.yml
name: Deploy Infrastructure
on:
  push:
    branches: [main]

jobs:
  terraform:
    uses: v-grand/infra-ci/.github/workflows/reusable/terraform-plan.yml@main
    with:
      working-directory: ./
      environment: dev
    secrets: inherit
```

---

**Pełna dokumentacja:** [English version](../en/infra-ci.md)
