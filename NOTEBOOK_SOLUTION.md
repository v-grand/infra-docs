# Решение для отображения Jupyter Notebooks

## Проблема
Ноутбуки не отображались на сайте, потому что:
- MkDocs ссылался на `.md` файлы
- Реальные файлы были в формате `.ipynb`
- Конвертация происходила только в CI через `jupyter nbconvert`
- Локально `.md` файлы не существовали

## Решение
Использован плагин **mkdocs-jupyter** - стабильное решение для отображения Jupyter notebooks в MkDocs.

### Преимущества:
✅ Работает напрямую с `.ipynb` файлами  
✅ Не требует ручной конвертации  
✅ Одинаково работает локально и в CI  
✅ Активно поддерживается (последний релиз: октябрь 2024)  
✅ Совместим с Material theme  

## Внесённые изменения

### 1. `.github/workflows/deploy-docs.yml`
**Было:**
```yaml
- name: Install dependencies
  run: |
    pip install mkdocs mkdocs-material mkdocs-i18n jupyter nbconvert

- name: Convert Notebooks to Markdown
  run: |
    find . -name "*.ipynb" -print0 | xargs -0 -I {} jupyter nbconvert --to markdown --output-dir=$(dirname {}) {}
```

**Стало:**
```yaml
- name: Install dependencies
  run: |
    pip install mkdocs mkdocs-material mkdocs-i18n mkdocs-jupyter
```

### 2. `mkdocs.yml`
**Изменения:**
1. Активирован плагин `mkdocs-jupyter` (строка 110)
2. Все ссылки на notebooks изменены с `.md` на `.ipynb`:
   - `notebooks/example.md` → `notebooks/example.ipynb`
   - `notebooks/ci-cd-pipeline.md` → `notebooks/ci-cd-pipeline.ipynb`
   - `notebooks/infra-core-usage.md` → `notebooks/infra-core-usage.ipynb`
   - `notebooks/tailscale-mesh.md` → `notebooks/tailscale-mesh.ipynb`
   - `notebooks/terraform-demo.md` → `notebooks/terraform-demo.ipynb`

Изменения применены во всех языковых секциях (en, ru, pl).

## Проверка

### В GitHub Actions
После push в `main` ветку:
1. GitHub Actions автоматически установит `mkdocs-jupyter`
2. MkDocs соберёт сайт с notebooks
3. Сайт будет опубликован на GitHub Pages

### Локальная проверка (если установлен Python)
```bash
# Установить зависимости
pip install mkdocs mkdocs-material mkdocs-i18n mkdocs-jupyter

# Запустить локальный сервер
mkdocs serve

# Проверить notebooks по адресам:
# http://127.0.0.1:8000/notebooks/example/
# http://127.0.0.1:8000/notebooks/ci-cd-pipeline/
# и т.д.
```

## Ссылки
- [mkdocs-jupyter на PyPI](https://pypi.org/project/mkdocs-jupyter/)
- [mkdocs-jupyter на GitHub](https://github.com/danielfrg/mkdocs-jupyter)
