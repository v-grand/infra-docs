# Скрипт для удаления terraform.tfvars файлов из репозиториев
# КРИТИЧЕСКАЯ ЗАДАЧА: Устранение потенциальной утечки данных

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  Удаление terraform.tfvars файлов" -ForegroundColor Cyan
Write-Host "  КРИТИЧЕСКАЯ ЗАДАЧА ПО БЕЗОПАСНОСТИ" -ForegroundColor Yellow
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""

$baseDir = "C:\Users\Administrator\.gemini"
$repositories = @(
    @{
        Name = "infra-gcp"
        Files = @(
            "environments\dev\terraform.tfvars",
            "environments\prod\terraform.tfvars"
        )
    },
    @{
        Name = "infra-monitoring"
        Files = @(
            "environments\prod\terraform.tfvars"
        )
    }
)

function Remove-TerraformVars {
    param (
        [string]$RepoName,
        [string[]]$FilePaths
    )
    
    $repoPath = Join-Path $baseDir $RepoName
    
    Write-Host "📁 Репозиторий: $RepoName" -ForegroundColor Green
    Write-Host "   Путь: $repoPath" -ForegroundColor Gray
    Write-Host ""
    
    if (-not (Test-Path $repoPath)) {
        Write-Host "   ❌ Репозиторий не найден!" -ForegroundColor Red
        Write-Host ""
        return
    }
    
    Set-Location $repoPath
    
    # Проверка статуса Git
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        Write-Host "   ⚠️  ВНИМАНИЕ: Есть незакоммиченные изменения!" -ForegroundColor Yellow
        Write-Host "   Текущий статус:" -ForegroundColor Yellow
        git status --short
        Write-Host ""
        $continue = Read-Host "   Продолжить? (y/n)"
        if ($continue -ne "y") {
            Write-Host "   ⏭️  Пропущено" -ForegroundColor Yellow
            Write-Host ""
            return
        }
    }
    
    foreach ($file in $FilePaths) {
        $fullPath = Join-Path $repoPath $file
        $examplePath = $fullPath + ".example"
        
        Write-Host "   📄 Обработка: $file" -ForegroundColor Cyan
        
        # Проверка существования файла
        if (-not (Test-Path $fullPath)) {
            Write-Host "      ℹ️  Файл не найден (возможно уже удален)" -ForegroundColor Gray
            continue
        }
        
        # Проверка существования .example файла
        if (-not (Test-Path $examplePath)) {
            Write-Host "      ⚠️  .example файл не найден!" -ForegroundColor Yellow
            Write-Host "      📝 Создаем .example файл..." -ForegroundColor Yellow
            
            # Копируем содержимое и заменяем чувствительные данные на placeholders
            $content = Get-Content $fullPath -Raw
            $content = $content -replace 'your-dev-gcp-project-id', 'your-dev-gcp-project-id'
            $content = $content -replace 'your-gcp-prod-project-id', 'your-gcp-prod-project-id'
            $content = $content -replace 'your-secure-grafana-prod-password', 'CHANGE_THIS_PASSWORD'
            
            Set-Content -Path $examplePath -Value $content
            git add $examplePath
            Write-Host "      ✅ .example файл создан" -ForegroundColor Green
        } else {
            Write-Host "      ✅ .example файл существует" -ForegroundColor Green
        }
        
        # Показываем содержимое для проверки
        Write-Host "      📋 Содержимое файла:" -ForegroundColor Cyan
        Get-Content $fullPath | ForEach-Object { Write-Host "         $_" -ForegroundColor Gray }
        Write-Host ""
        
        # Спрашиваем подтверждение
        Write-Host "      ⚠️  Удалить этот файл из Git?" -ForegroundColor Yellow
        $confirm = Read-Host "      (y/n)"
        
        if ($confirm -eq "y") {
            # Удаляем из Git
            git rm $file 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "      ✅ Файл удален из Git" -ForegroundColor Green
            } else {
                # Если файл не в Git, просто удаляем
                Remove-Item $fullPath -Force
                Write-Host "      ✅ Файл удален из файловой системы" -ForegroundColor Green
            }
        } else {
            Write-Host "      ⏭️  Пропущено" -ForegroundColor Yellow
        }
        
        Write-Host ""
    }
    
    # Проверка изменений
    $changes = git status --porcelain
    if ($changes) {
        Write-Host "   📊 Изменения для коммита:" -ForegroundColor Cyan
        git status --short
        Write-Host ""
        
        Write-Host "   💾 Создать коммит?" -ForegroundColor Yellow
        $commitConfirm = Read-Host "   (y/n)"
        
        if ($commitConfirm -eq "y") {
            $commitMessage = "security: Remove sensitive terraform.tfvars files

- Removed terraform.tfvars from repository
- Added terraform.tfvars.example as template
- Sensitive values should be managed via GitHub Secrets or SOPS

Related to: Infrastructure Audit Remediation Task #2"
            
            git commit -m $commitMessage
            Write-Host "   ✅ Коммит создан" -ForegroundColor Green
            Write-Host ""
            
            Write-Host "   🚀 Отправить в remote?" -ForegroundColor Yellow
            $pushConfirm = Read-Host "   (y/n)"
            
            if ($pushConfirm -eq "y") {
                git push
                Write-Host "   ✅ Изменения отправлены" -ForegroundColor Green
            } else {
                Write-Host "   ℹ️  Не забудьте выполнить 'git push' позже" -ForegroundColor Cyan
            }
        }
    } else {
        Write-Host "   ℹ️  Нет изменений для коммита" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "─────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host ""
}

# Основной процесс
Write-Host "🔍 Начинаем проверку репозиториев..." -ForegroundColor Cyan
Write-Host ""

foreach ($repo in $repositories) {
    Remove-TerraformVars -RepoName $repo.Name -FilePaths $repo.Files
}

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "  ✅ Проверка завершена!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📝 Следующие шаги:" -ForegroundColor Yellow
Write-Host "   1. Проверьте, что .example файлы не содержат реальных секретов" -ForegroundColor White
Write-Host "   2. Убедитесь, что terraform.tfvars добавлен в .gitignore" -ForegroundColor White
Write-Host "   3. Если были реальные секреты, очистите Git историю:" -ForegroundColor White
Write-Host "      git filter-branch --force --index-filter \" -ForegroundColor Gray
Write-Host "        \`"git rm --cached --ignore-unmatch terraform.tfvars\`" \" -ForegroundColor Gray
Write-Host "        --prune-empty --tag-name-filter cat -- --all" -ForegroundColor Gray
Write-Host "      git push origin --force --all" -ForegroundColor Gray
Write-Host ""
Write-Host "📊 Отчеты:" -ForegroundColor Yellow
Write-Host "   - REMEDIATION_SUMMARY.md - краткая сводка" -ForegroundColor White
Write-Host "   - REMEDIATION_VERIFICATION.md - полный отчет" -ForegroundColor White
Write-Host ""

# Возвращаемся в исходную директорию
Set-Location $baseDir
