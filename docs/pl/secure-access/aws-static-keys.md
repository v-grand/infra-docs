# Statyczne klucze AWS

!!! danger "Nie zalecane"
    Używanie statycznych kluczy dostępu użytkownika IAM **nie jest zalecane** do programowego dostępu. W miarę możliwości zawsze preferuj tymczasowe poświadczenia, używając metod takich jak **[AWS OIDC](aws-oidc.md)**. Klucze statyczne to długoterminowe poświadczenia, które mogą stanowić znaczne ryzyko bezpieczeństwa w przypadku ich kompromitacji.

## Przegląd

Ta metoda polega na utworzeniu użytkownika IAM z dedykowanym zestawem długoterminowych kluczy dostępu (`Access Key ID` i `Secret Access Key`). Klucze te są następnie konfigurowane jako zmienne środowiskowe lub w pliku poświadczeń, których AWS SDK lub CLI używają do uwierzytelniania żądań.

## Przypadki użycia

Używaj kluczy statycznych tylko wtedy, gdy tymczasowe poświadczenia nie są realną opcją, na przykład:
- Starsza aplikacja, która не obsługuje nowoczesnych przepływów uwierzytelniania.
- Specyficzne narzędzia firm trzecich, które wymagają długoterminowych kluczy.
- Scenariusze początkowej konfiguracji lub "bootstrapping" przed skonfigurowaniem bezpieczniejszych metod.

## Konfiguracja

Jeśli musisz używać kluczy statycznych, skonfiguruj je jako zmienne środowiskowe:

```bash
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
export AWS_REGION=us-east-1
```

## Najlepsze praktyki bezpieczeństwa

- **Zasada najmniejszych uprawnień**: Udzielaj użytkownikowi IAM tylko tych uprawnień, których absolutnie potrzebuje.
- **Rotacja kluczy**: Regularnie zmieniaj klucze dostępu, aby ograniczyć okno możliwości ich nadużycia w przypadku kompromitacji.
- **Monitorowanie**: Używaj AWS CloudTrail do monitorowania wszystkich wywołań API wykonanych za pomocą kluczy statycznych. Skonfiguruj alerty dotyczące nietypowej aktywności.
- **Nie przechowuj kluczy w kodzie**: Nigdy nie umieszczaj kluczy dostępu bezpośrednio w kodzie. Używaj zmiennych środowiskowych lub bezpiecznego narzędzia do zarządzania sekretami.
