# Setup Tauri + Vue + React + TypeScript para Steam Mods Downloader
# Executar no PowerShell dentro do VSCode

param(
    [string]$ProjectName = "steam-mods-downloader"
)

Write-Host "=== Setup Tauri Steam Mods Downloader ===" -ForegroundColor Cyan

# Verificar se Node.js está instalado
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Erro: Node.js não está instalado. Instale em https://nodejs.org/" -ForegroundColor Red
    exit 1
}

# Verificar se Rust está instalado
if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "Erro: Rust não está instalado. Instale em https://rustup.rs/" -ForegroundColor Red
    exit 1
}

# Criar diretório do projeto
$projectPath = Join-Path $PWD $ProjectName
if (Test-Path $projectPath) {
    Write-Host "Diretório já existe: $projectPath" -ForegroundColor Yellow
} else {
    New-Item -ItemType Directory -Path $projectPath | Out-Null
}

Set-Location $projectPath

# Inicializar projeto Tauri com Vite + React + TypeScript
Write-Host "`n=== Criando projeto Tauri + Vite + React + TypeScript ===" -ForegroundColor Cyan
npm create tauri-app@latest . -- --template react-ts --manager npm --yes

# Instalar dependências
Write-Host "`n=== Instalando dependências ===" -ForegroundColor Cyan
npm install

# Criar estrutura de pastas
Write-Host "`n=== Criando estrutura de pastas ===" -ForegroundColor Cyan

# Pasta steamcmd
$steamcmdPath = Join-Path $projectPath "steamcmd"
if (-not (Test-Path $steamcmdPath)) {
    New-Item -ItemType Directory -Path $steamcmdPath | Out-Null
}

# Script steam.cmd
$steamCmdScript = @"
@echo off
echo ========================================
echo STEAMCMD - Anonymous Login
echo ========================================
echo.
echo Iniciando login anonymous...
echo.
steamcmd.exe +login anonymous +quit
echo.
echo Login concluido. Aguardando comandos...
echo.
echo Comando para download: workshop_download_item <app_id> <publishedfileid>
echo Exemplo: workshop_download_item 730 123456789
echo.
pause
"@
$steamCmdScript | Out-File -FilePath (Join-Path $steamcmdPath "steam.cmd") -Encoding UTF8

# Pasta assets
$assetsPath = Join-Path $projectPath "src-tauri" "icons"
if (-not (Test-Path $assetsPath)) {
    New-Item -ItemType Directory -Path $assetsPath | Out-Null
}

# Criar ícone placeholder (PNG vazio 1x1 pixel)
$placeholderIcon = [System.Drawing.Bitmap]::new(1, 1)
$placeholderIcon.Save((Join-Path $assetsPath "icon.png"))
$placeholderIcon.Dispose()

# Criar arquivo de configuração otimizado para máquinas fracas
$tomlPath = Join-Path $projectPath "src-tauri" "Cargo.toml"
if (Test-Path $tomlPath) {
    $content = Get-Content $tomlPath -Raw
    # Adicionar otimizações de release
    if ($content -notmatch '\[profile\.release\]') {
        $optimizedProfile = @"

[profile.release]
lto = true
codegen-units = 1
opt-level = "z"
strip = true
panic = "abort"

[profile.dev]
opt-level = 0
debug = false
strip = "debuginfo"
"@
        $content += $optimizedProfile
        $content | Out-File -FilePath $tomlPath -Encoding UTF8
    }
}

Write-Host "`n=== Setup concluído! ===" -ForegroundColor Green
Write-Host "Projeto criado em: $projectPath" -ForegroundColor Green
Write-Host "`nPróximos passos:" -ForegroundColor Yellow
Write-Host "1. Execute 'npm run tauri dev' para desenvolvimento" -ForegroundColor White
Write-Host "2. Execute 'npm run tauri build' para compilar" -ForegroundColor White
Write-Host "3. A pasta 'steamcmd' contém o script steam.cmd" -ForegroundColor White
Write-Host "4. O ícone está em 'src-tauri/icons/icon.png'" -ForegroundColor White
