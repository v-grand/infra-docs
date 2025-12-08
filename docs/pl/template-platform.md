# Template Platform

**Template Platform** to fundamentalna usługa backendowa, zaprojektowana jako gotowy do użycia, skalowalny i łatwy w utrzymaniu punkt wyjścia для nowych aplikacji. Integruje się bezproblemowo z komponentami infrastruktury dostarczanymi przez `infra-core` i `infra-template`, a jej wdrożenie jest zarządzane przez potoki z `infra-ci`.

## Główny cel

Głównym celem `template-platform` jest przyspieszenie rozwoju poprzez oferowanie wstępnie skonfigurowanego środowiska, które obejmuje:

- **Szablon API**: Podstawowa struktura do tworzenia API RESTful lub GraphQL.
- **Integracja z bazą danych**: Wstępnie skonfigurowane połączenia ze standardowymi bazami danych.
- **Integracja z CI/CD**: Gotowość do wdrożenia w środowiskach `dev` i `stage` od razu po wyjęciu z pudełka, przy użyciu `infra-ci`.
- **Obserwowalność (Observability)**: Haki do logowania, metryk i śledzenia.

## Pierwsze kroki

Aby rozpocząć pracę z `template-platform`, upewnij się, że sklonowałeś repozytorium i zainicjowałeś jego submoduły:

```bash
git clone <your-repo-url>/template-platform.git
cd template-platform
git submodule update --init --recursive
```

Usługę można uruchomić lokalnie za pomocą Docker Compose:

```bash
docker-compose up --build
```

## Wdrożenie

Wdrożenia są obsługiwane automatycznie przez GitHub Actions po wypchnięciu do gałęzi `main` (dla środowiska `dev`) lub mogą być uruchamiane ręcznie (dla środowiska `stage`). Potok wykorzystuje konfiguracje Terraform zdefiniowane w repozytorium `template-platform`, które z kolei korzystają z modułów z `infra-template`.
