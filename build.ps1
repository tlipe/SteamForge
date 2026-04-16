# Build script para gerar instalador NSIS do Steam Mods Downloader
# Executar após o setup inicial

Write-Host "=== Build Steam Mods Downloader (NSIS) ===" -ForegroundColor Cyan

# Verificar se está no diretório correto
if (-not (Test-Path "src-tauri")) {
    Write-Host "Erro: Execute este script no diretório raiz do projeto Tauri" -ForegroundColor Red
    exit 1
}

# Verificar dependências
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Erro: Node.js necessário" -ForegroundColor Red
    exit 1
}

if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "Erro: Rust necessário" -ForegroundColor Red
    exit 1
}

# Instalar dependências frontend
Write-Host "`n=== Instalando dependências frontend ===" -ForegroundColor Cyan
npm install --production

# Build do frontend
Write-Host "`n=== Compilando frontend ===" -ForegroundColor Cyan
npm run build

# Build Tauri com NSIS
Write-Host "`n=== Compilando aplicativo Tauri (NSIS) ===" -ForegroundColor Cyan
Write-Host "Isso pode demorar alguns minutos..." -ForegroundColor Yellow

# Configurar para build NSIS
$tauriConfigPath = Join-Path $PWD "src-tauri" "tauri.conf.json"
if (Test-Path $tauriConfigPath) {
    $config = Get-Content $tauriConfigPath | ConvertFrom-Json
    
    # Garantir que NSIS está habilitado
    if ($config.bundle -eq $null) {
        $config | Add-Member -NotePropertyName "bundle" -NotePropertyValue (@{ })
    }
    
    if ($config.bundle.windows -eq $null) {
        $config.bundle | Add-Member -NotePropertyName "windows" -NotePropertyValue (@{ })
    }
    
    if ($config.bundle.windows.wix -eq $null -and $config.bundle.windows.nsis -eq $null) {
        $config.bundle.windows | Add-Member -NotePropertyName "nsis" -NotePropertyValue (@{ })
    }
    
    $config | ConvertTo-Json -Depth 10 | Out-File -FilePath $tauriConfigPath -Encoding UTF8
}

# Executar build
npm run tauri build

# Verificar output
$distPath = Join-Path $PWD "src-tauri" "target" "release" "bundle" "nsis"
if (Test-Path $distPath) {
    Write-Host "`n=== Build concluído com sucesso! ===" -ForegroundColor Green
    Write-Host "Instaladores NSIS em:" -ForegroundColor Green
    Get-ChildItem -Path $distPath -Filter "*.exe" | ForEach-Object {
        Write-Host "  - $($_.FullName)" -ForegroundColor White
    }
} else {
    Write-Host "`n=== Build concluído, mas instalador NSIS não encontrado ===" -ForegroundColor Yellow
    Write-Host "Verifique em: src-tauri/target/release/bundle/" -ForegroundColor White
}

Write-Host "`nDica: Para builds mais rápidos em máquinas fracas, use:" -ForegroundColor Cyan
Write-Host "  cargo build --release --target x86_64-pc-windows-msvc" -ForegroundColor White
