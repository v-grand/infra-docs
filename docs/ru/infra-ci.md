# Быстрый старт: infra-ci

Документация находится в процессе перевода.

См. [English version](../en/infra-ci.md) для полной документации.

## Краткое описание

**infra-ci** - централизованный репозиторий с переиспользуемыми GitHub Actions workflows для автоматизации CI/CD процессов.

## Основные возможности

- Переиспользуемые Terraform workflows
- Автоматическая валидация кода
- Интеграция с SOPS для секретов
- Поддержка multi-cloud развёртываний

## Быстрое использование

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

**Полная документация:** [English version](../en/infra-ci.md)
