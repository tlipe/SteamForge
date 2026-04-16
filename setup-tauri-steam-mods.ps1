# Setup Tauri + Vue + TypeScript com Otimizações Extremas
Write-Host "=== Iniciando Setup Tauri Steam Mods ===" -ForegroundColor Cyan

$projectName = "steam-mod-downloader"

# 1. Criar Projeto Vite (Vue + TS) forçadamente
Write-Host "Criando frontend Vite..." -ForegroundColor Yellow
if (Test-Path $projectName) {
    Remove-Item -Recurse -Force $projectName
}
# Usa npx com yes para evitar prompts e especifica template vue-ts
npx --yes create-vite@latest $projectName --template vue-ts
if ($LASTEXITCODE -ne 0) { throw "Falha ao criar projeto Vite" }

Set-Location $projectName

# 2. Instalar Dependências
Write-Host "Instalando dependências Node..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) { throw "Falha no npm install" }

# 3. Instalar Tauri CLI e Inicializar
Write-Host "Instalando Tauri CLI..." -ForegroundColor Yellow
npm install --save-dev @tauri-apps/cli@latest
if ($LASTEXITCODE -ne 0) { throw "Falha ao instalar Tauri CLI" }

Write-Host "Inicializando Tauri (Gerando Rust)..." -ForegroundColor Yellow
# Inicializa com gerenciador npm, nome do bundle genérico eAppName
npx tauri init --app-name $projectName --window-title "Steam Mod Downloader" --bundle-identifier "com.steam.modder" --manager npm
if ($LASTEXITCODE -ne 0) { throw "Falha ao inicializar Tauri" }

# 4. Otimizações Rust para Máquinas Fracas
Write-Host "Aplicando otimizações Rust (LTO, Strip, etc)..." -ForegroundColor Green
$cargoPath = "src-tauri/Cargo.toml"

# Lê o arquivo
$content = Get-Content $cargoPath -Raw

# Adiciona perfil de release otimizado se não existir
if ($content -notmatch "\[profile\.release\]") {
    $optimizedProfile = @"

# Otimização extrema para máquinas fracas
[profile.release]
lto = true
codegen-units = 1
opt-level = "z"      # Otimiza para tamanho (menor binário, menos uso de RAM)
strip = true         # Remove símbolos de debug
panic = "abort"      # Aborta em pânico ao invés de unwinding (menor código)

[profile.dev]
opt-level = 1        # Dev um pouco mais rápido mas ainda compilável
"@
    $content += $optimizedProfile
    Set-Content $cargoPath $content
}

# 5. Estrutura de Pastas e Assets
Write-Host "Criando estrutura de pastas..." -ForegroundColor Green

# Pasta steamcmd dentro de src-tauri (para o usuário colocar o steamcmd.exe depois)
$steamCmdDir = "src-tauri/steamcmd"
if (!(Test-Path $steamCmdDir)) {
    New-Item -ItemType Directory -Force $steamCmdDir | Out-Null
    Write-Host "Pasta '$steamCmdDir' criada. Coloque seu steamcmd.exe lá." -ForegroundColor Magenta
}

# Pasta assets/icons para o ícone vazio
$iconsDir = "src-tauri/icons"
if (!(Test-Path $iconsDir)) {
    New-Item -ItemType Directory -Force $iconsDir | Out-Null
}
# Cria um placeholder de texto para o ícone (já que não podemos gerar PNG binário facilmente aqui)
$placeholderPath = "src-tauri/icons/empty_icon_placeholder.txt"
Set-Content $placeholderPath "Substitua este arquivo por um icon.png ou .ico real futuramente."

# 6. Atualizar Código Frontend (Visual Azul Neon + Grid)
Write-Host "Configurando Interface (Vue + CSS Neon)..." -ForegroundColor Green

# App.vue
Set-Content "src/App.vue" @"
<script setup lang="ts">
import { ref } from 'vue'
import { invoke } from '@tauri-apps/api/core'

const steamGameId = ref('')
const modLinks = ref('')
const statusMsg = ref('Aguardando comando...')
const isDownloading = ref(false)

async function startDownload() {
  if (!steamGameId.value || !modLinks.value) {
    statusMsg.value = 'Erro: Preencha o ID do Jogo e os Links!'
    return
  }

  isDownloading.value = true
  statusMsg.value = 'Processando links e iniciando downloads...'

  try {
    // Chama o backend Rust
    const result = await invoke('process_mods', { 
      gameId: steamGameId.value, 
      links: modLinks.value 
    })
    statusMsg.value = String(result)
  } catch (e) {
    statusMsg.value = 'Erro no download: ' + e
  } finally {
    isDownloading.value = false
  }
}
</script>

<template>
  <div class="container">
    <div class="grid-bg"></div>
    
    <main class="glass-panel">
      <h1>Steam Mod Downloader</h1>
      
      <div class="input-group">
        <label>ID do Jogo (Steam App ID)</label>
        <input 
          v-model="steamGameId" 
          type="text" 
          placeholder="Ex: 730 (CS:GO)" 
          class="neon-input"
        />
      </div>

      <div class="input-group">
        <label>Cole os Links dos Mods (Um por linha ou separados)</label>
        <textarea 
          v-model="modLinks" 
          placeholder="https://steamcommunity.com/sharedfiles/filedetails/?id=123456..." 
          class="neon-textarea"
        ></textarea>
      </div>

      <button @click="startDownload" :disabled="isDownloading" class="neon-btn">
        {{ isDownloading ? 'BAIXANDO...' : 'GO' }}
      </button>

      <div class="status-box">
        {{ statusMsg }}
      </div>
    </main>
  </div>
</template>

<style scoped>
.container {
  position: relative;
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  font-family: 'Segoe UI', sans-serif;
  overflow: hidden;
  background-color: #050510;
}

/* Background Grid Animado */
.grid-bg {
  position: absolute;
  width: 200%;
  height: 200%;
  background-image: 
    linear-gradient(rgba(0, 255, 255, 0.1) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 255, 255, 0.1) 1px, transparent 1px);
  background-size: 40px 40px;
  transform: perspective(500px) rotateX(60deg) translateY(-100px) translateZ(-200px);
  animation: gridMove 20s linear infinite;
  z-index: 0;
  pointer-events: none;
}

@keyframes gridMove {
  0% { transform: perspective(500px) rotateX(60deg) translateY(0) translateZ(-200px); }
  100% { transform: perspective(500px) rotateX(60deg) translateY(40px) translateZ(-200px); }
}

.glass-panel {
  position: relative;
  z-index: 1;
  background: rgba(10, 20, 40, 0.7);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(0, 255, 255, 0.3);
  padding: 2rem;
  border-radius: 15px;
  width: 90%;
  max-width: 500px;
  box-shadow: 0 0 20px rgba(0, 255, 255, 0.2);
  text-align: center;
  color: #fff;
}

h1 {
  color: #00ffff;
  text-shadow: 0 0 10px #00ffff;
  margin-bottom: 1.5rem;
  font-size: 1.8rem;
}

.input-group {
  text-align: left;
  margin-bottom: 1rem;
}

label {
  display: block;
  color: #00cccc;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
  text-shadow: 0 0 5px rgba(0, 204, 204, 0.5);
}

.neon-input, .neon-textarea {
  width: 100%;
  background: rgba(0, 0, 0, 0.5);
  border: 1px solid #00ffff;
  color: #fff;
  padding: 10px;
  border-radius: 5px;
  outline: none;
  box-sizing: border-box;
  transition: all 0.3s ease;
}

.neon-input:focus, .neon-textarea:focus {
  box-shadow: 0 0 15px rgba(0, 255, 255, 0.5);
  background: rgba(0, 255, 255, 0.05);
}

.neon-textarea {
  height: 100px;
  resize: vertical;
}

.neon-btn {
  width: 100%;
  padding: 12px;
  background: transparent;
  border: 2px solid #00ffff;
  color: #00ffff;
  font-weight: bold;
  font-size: 1.2rem;
  border-radius: 5px;
  cursor: pointer;
  text-transform: uppercase;
  letter-spacing: 2px;
  transition: all 0.3s ease;
  box-shadow: 0 0 10px rgba(0, 255, 255, 0.3);
  margin-top: 1rem;
}

.neon-btn:hover:not(:disabled) {
  background: #00ffff;
  color: #000;
  box-shadow: 0 0 30px rgba(0, 255, 255, 0.8);
  transform: scale(1.05); /* Zoom effect only */
}

.neon-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  border-color: #555;
  color: #555;
}

.status-box {
  margin-top: 1.5rem;
  padding: 10px;
  background: rgba(0, 0, 0, 0.3);
  border-radius: 5px;
  font-family: monospace;
  font-size: 0.9rem;
  color: #aaa;
  border-left: 3px solid #00ffff;
}
</style>
"@

# 7. Configurar Backend Rust (src-tauri/src/lib.rs)
Write-Host "Configurando Backend Rust..." -ForegroundColor Green
Set-Content "src-tauri/src/lib.rs" @"
use std::process::Command;
use std::path::PathBuf;

#[tauri::command]
fn process_mods(game_id: String, links: String) -> Result<String, String> {
    // Extrai IDs dos links da Steam
    let mut mod_ids: Vec<String> = Vec::new();
    
    for line in links.lines() {
        let trimmed = line.trim();
        if trimmed.is_empty() { continue; }
        
        // Tenta extrair o ID após "?id="
        if let Some(pos) = trimmed.find("?id=") {
            let id_part = &trimmed[pos + 4..];
            // Pega apenas números até o próximo caractere não numérico ou fim da string
            let clean_id: String = id_part.chars().take_while(|c| c.is_ascii_digit()).collect();
            if !clean_id.is_empty() {
                mod_ids.push(clean_id);
            }
        }
    }

    if mod_ids.is_empty() {
        return Err("Nenhum ID de mod válido encontrado nos links.".to_string());
    }

    // Caminho para o steamcmd (relativo ao executável ou hardcoded se necessário)
    // Em produção, o steamcmd estará junto com o binário ou em resources
    // Aqui assumimos que está numa pasta 'steamcmd' ao lado do executável ou no diretório de trabalho
    let steamcmd_path = PathBuf::from("steamcmd/steamcmd.exe");
    
    // Verifica se existe, senão tenta o caminho absoluto ou relativo comum
    let final_steamcmd = if steamcmd_path.exists() {
        steamcmd_path
    } else {
        // Fallback: tenta procurar no PATH ou retorna erro instrutivo
        // Para desenvolvimento, vamos assumir que o usuário colocou na pasta correta
        PathBuf::from("./steamcmd/steamcmd.exe")
    };

    if !final_steamcmd.exists() {
        return Err(format!("steamcmd.exe não encontrado em {:?}. Por favor, coloque a pasta steamcmd com o exe no local correto.", final_steamcmd));
    }

    let mut results = String::new();
    
    for mod_id in mod_ids {
        let cmd_args = format!("+login anonymous +workshop_download_item {} {} +quit", game_id, mod_id);
        
        // Executa o steamcmd
        let output = Command::new(&final_steamcmd)
            .args(cmd_args.split_whitespace())
            .output();

        match output {
            Ok(out) => {
                if out.status.success() {
                    results.push_str(&format!("Mod {} baixado com sucesso!\n", mod_id));
                } else {
                    let stderr = String::from_utf8_lossy(&out.stderr);
                    results.push_str(&format!("Erro ao baixar mod {}: {}\n", mod_id, stderr));
                }
            },
            Err(e) => {
                results.push_str(&format!("Falha ao executar steamcmd para mod {}: {}\n", mod_id, e));
            }
        }
    }

    Ok(if results.is_empty() { "Processo finalizado.".to_string() } else { results })
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![process_mods])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
"@

# 8. Criar build.ps1
Write-Host "Criando script de Build (NSIS)..." -ForegroundColor Green
Set-Content "../build.ps1" @"
Write-Host "=== Iniciando Build Final (NSIS) ===" -ForegroundColor Cyan

# 1. Build do Frontend
Write-Host "Compilando Frontend..." -ForegroundColor Yellow
npm run build
if (`$LASTEXITCODE -ne 0) { throw "Falha no build do frontend" }

# 2. Build do Tauri (Rust + Empacotamento)
Write-Host "Compilando Rust e Gerando Instalador NSIS..." -ForegroundColor Yellow
# O flag --bundle gera o instalador
npx tauri build --bundle nsis
if (`$LASTEXITCODE -ne 0) { throw "Falha no build do Tauri" }

Write-Host "=== Build Concluído! ===" -ForegroundColor Green
Write-Host "Os instaladores estão em: src-tauri/target/release/bundle/nsis/" -ForegroundColor Magenta
"@

Write-Host "=== Setup Finalizado com Sucesso! ===" -ForegroundColor Green
Write-Host "Próximos passos:" -ForegroundColor Yellow
Write-Host "1. Coloque seus arquivos do steamcmd.exe dentro da pasta 'src-tauri/steamcmd/'" -ForegroundColor White
Write-Host "2. Execute '.\build.ps1' para gerar o instalador." -ForegroundColor White
