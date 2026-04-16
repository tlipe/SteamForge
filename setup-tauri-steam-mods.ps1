# Setup Tauri + Vue + TypeScript para Steam Mods Downloader
# Otimizado para máquinas fracas - usuário deve colocar sua própria pasta steamcmd com steamcmd.exe

param(
    [string]$ProjectName = "steam-mods-downloader"
)

Write-Host "=== Iniciando Setup do Projeto Tauri ===" -ForegroundColor Cyan

# 1. Criar projeto Vite com Vue + TypeScript
Write-Host "Criando projeto Vite com Vue e TypeScript..." -ForegroundColor Yellow
npm create vite@latest $ProjectName -- --template vue-ts

if (-not (Test-Path $ProjectName)) {
    Write-Host "Erro: Falha ao criar projeto Vite." -ForegroundColor Red
    exit 1
}

Set-Location $ProjectName

# 2. Instalar dependências do frontend
Write-Host "Instalando dependências do frontend..." -ForegroundColor Yellow
npm install

# 3. Adicionar Tauri
Write-Host "Adicionando Tauri..." -ForegroundColor Yellow
npm install -D @tauri-apps/cli @tauri-apps/api

# 4. Inicializar Tauri
Write-Host "Inicializando configuração do Tauri..." -ForegroundColor Yellow
npx tauri init --name "SteamModsDownloader" --identifier "com.steammods.downloader" --dev-path "http://localhost:5173" --dist-dir "../dist" --before-dev-command "npm run dev" --before-build-command "npm run build"

# 5. Configurar otimizações Rust para máquinas fracas
Write-Host "Aplicando otimizações Rust para máquinas fracas..." -ForegroundColor Yellow

$CargoTomlPath = "src-tauri/Cargo.toml"
$CargoContent = Get-Content $CargoTomlPath -Raw

if ($CargoContent -notmatch '\[profile\.release\]') {
    $OptimizedProfile = @"

[profile.release]
panic = "abort"
codegen-units = 1
lto = true
opt-level = "z"
strip = true

"@
    $CargoContent += $OptimizedProfile
    Set-Content -Path $CargoTomlPath -Value $CargoContent
    Write-Host "Perfil de release otimizado adicionado." -ForegroundColor Green
}

# 6. Criar estrutura de pastas steamcmd e assets
Write-Host "Criando estrutura de pastas..." -ForegroundColor Yellow

$SteamCmdPath = "src-tauri/steamcmd"
$AssetsPath = "src-tauri/assets"
$IconsPath = "src-tauri/assets/icons"

if (-not (Test-Path $SteamCmdPath)) {
    New-Item -ItemType Directory -Path $SteamCmdPath | Out-Null
    Write-Host "Pasta steamcmd criada em: $SteamCmdPath" -ForegroundColor Green
    Write-Host ">>> COLOQUE SUA PASTA steamcmd (COM steamcmd.exe) DENTRO DESTA PASTA <<<" -ForegroundColor Magenta
}

if (-not (Test-Path $AssetsPath)) {
    New-Item -ItemType Directory -Path $AssetsPath | Out-Null
}

if (-not (Test-Path $IconsPath)) {
    New-Item -ItemType Directory -Path $IconsPath | Out-Null
}

# Criar placeholder para o ícone
$IconPlaceholder = "src-tauri/assets/icons/icon.png"
if (-not (Test-Path $IconPlaceholder)) {
    "# Placeholder para icon.png - Substitua por seu arquivo PNG 512x512 ou 256x256" | Out-File -FilePath $IconPlaceholder
    Write-Host "Placeholder para ícone criado em: $IconPlaceholder" -ForegroundColor Yellow
    Write-Host ">>> SUBSTITUA ESTE ARQUIVO PELO SEU icon.png <<<" -ForegroundColor Magenta
}

# 7. Atualizar tauri.conf.json para usar o ícone customizado
Write-Host "Configurando tauri.conf.json..." -ForegroundColor Yellow

$TauriConfPath = "src-tauri/tauri.conf.json"
if (Test-Path $TauriConfPath) {
    $TauriConf = Get-Content $TauriConfPath -Raw | ConvertFrom-Json
    $TauriConf.bundle.icon = @("assets/icons/icon.png")
    $TauriConf | ConvertTo-Json -Depth 100 | Set-Content $TauriConfPath
    Write-Host "tauri.conf.json atualizado." -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Setup Concluído ===" -ForegroundColor Green
Write-Host ""
Write-Host "Próximos passos:" -ForegroundColor Cyan
Write-Host "1. Coloque sua pasta steamcmd (contendo steamcmd.exe) em: .\$ProjectName\src-tauri\steamcmd\"
Write-Host "2. Substitua o placeholder em: .\$ProjectName\src-tauri\assets\icons\icon.png pelo seu ícone"
Write-Host "3. Execute 'npm run tauri dev' para testar"
Write-Host "4. Execute '.\build.ps1' para gerar o instalador NSIS"
Write-Host ""
