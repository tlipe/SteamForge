# Build script para gerar instalador NSIS
Write-Host "=== Iniciando Build do Projeto ===" -ForegroundColor Cyan

# Instalar dependências se necessário
if (-not (Test-Path "node_modules")) {
    Write-Host "Instalando dependências do frontend..." -ForegroundColor Yellow
    npm install
}

# Build do frontend
Write-Host "Compilando frontend..." -ForegroundColor Yellow
npm run build

# Build do Tauri com target NSIS
Write-Host "Compilando aplicativo Tauri e gerando instalador NSIS..." -ForegroundColor Yellow
npx tauri build --target x86_64-pc-windows-msvc --bundles nsis

Write-Host "=== Build Concluído ===" -ForegroundColor Green
Write-Host "Instaladores disponíveis em:" -ForegroundColor Cyan
Write-Host "  - src-tauri/target/release/bundle/nsis/" -ForegroundColor White
