# Использование infra-deployer

`infra-deployer` - это инструмент для автоматизированного развертывания инфраструктуры.

## Установка

\`\`\`bash
git clone https://github.com/v-grand/infra-deployer.git
cd infra-deployer
pip install -r requirements.txt
\`\`\`

## Использование

### Развертывание всех модулей

\`\`\`bash
python -m deploy.cli deploy all
\`\`\`

### Развертывание конкретного модуля

\`\`\`bash
python -m deploy.cli deploy core
\`\`\`

### Уничтожение всех модулей

\`\`\`bash
python -m deploy.cli destroy all
\`\`\`
