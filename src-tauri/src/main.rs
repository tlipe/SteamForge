#![cfg_attr(all(not(debug_assertions), target_os = "windows"), windows_subsystem = "windows")]

use std::process::{Command, Stdio};
use std::io::{BufRead, BufReader};
use tauri::Window;
use regex::Regex;
use std::sync::Arc;
use tokio::sync::Semaphore;

// Funcao ASSINCRONA para buscar o nome do mod
async fn get_mod_name(mod_id: &str) -> String {
    let url = format!("https://steamcommunity.com/sharedfiles/filedetails/?id={}", mod_id);
    let client = reqwest::Client::builder()
        .user_agent("Mozilla/5.0")
        .build()
        .unwrap_or_default();
    
    if let Ok(res) = client.get(url).send().await {
        if let Ok(html) = res.text().await {
            let re = Regex::new(r#"<div class="workshopItemTitle">(.*?)</div>"#).unwrap();
            if let Some(caps) = re.captures(&html) {
                return caps.get(1).map_or(mod_id.to_string(), |m| m.as_str().to_string());
            }
        }
    }
    mod_id.to_string()
}

#[tauri::command]
async fn download_mods(window: Window, game_id: String, items: Vec<String>) -> Result<String, String> {
    let exe_path = std::env::current_exe().map_err(|e| e.to_string())?;
    let mut project_root = exe_path.clone();
    while project_root.pop() {
        if project_root.join("steamcmd").exists() { break; }
    }
    let steamcmd_dir = project_root.join("steamcmd");
    let steamcmd_path = steamcmd_dir.join("steamcmd.exe");

    let re = Regex::new(r"(\d+)").unwrap();
    let mod_ids: Vec<String> = items.iter()
        .filter_map(|item| re.captures(item))
        .map(|cap| cap[1].to_string())
        .filter(|id| id != &game_id)
        .collect();

    if mod_ids.is_empty() { return Err("Nenhum ID detectado.".to_string()); }

    let semaphore = Arc::new(Semaphore::new(2));
    let mut handles = Vec::new();

    for mid in mod_ids {
        let window = window.clone();
        let steamcmd_path = steamcmd_path.clone();
        let steamcmd_dir = steamcmd_dir.clone();
        let game_id = game_id.clone();
        let permit = semaphore.clone().acquire_owned().await.unwrap();

        let handle = tokio::spawn(async move {
            let mod_name = get_mod_name(&mid).await; // Agora eh await real
            window.emit("download-log", format!("> Iniciando: {}", mod_name)).ok();

            let mut child = Command::new(&steamcmd_path)
                .args(&["+login", "anonymous", "+force_install_dir", &steamcmd_dir.to_string_lossy(), "+workshop_download_item", &game_id, &mid, "validate", "+quit"])
                .current_dir(&steamcmd_dir)
                .stdout(Stdio::piped())
                .spawn()
                .expect("Falha ao abrir SteamCMD");

            if let Some(stdout) = child.stdout.take() {
                let reader = BufReader::new(stdout);
                for line in reader.lines().flatten() {
                    if line.contains("Download item") || line.contains("Success") {
                        window.emit("download-log", format!("[{}] {}", mod_name, line)).ok();
                    }
                }
            }
            let _ = child.wait();

            // So cria o arquivo se a pasta existir (confirmando download)
            let mod_path = steamcmd_dir.join("steamapps").join("workshop").join("content").join(&game_id).join(&mid);
            if mod_path.exists() {
                let safe_name = mod_name.replace(|c: char| !c.is_alphanumeric() && c != ' ', "-");
                let _ = std::fs::write(mod_path.join(format!("!_NAME_{}.txt", safe_name)), &mod_name);
            }

            drop(permit);
        });
        handles.push(handle);
    }

    for handle in handles { let _ = handle.await; }

    Ok("Processo de fila concluido.".to_string())
}

#[tauri::command]
async fn open_mods_folder(game_id: String) -> Result<(), String> {
    let exe_path = std::env::current_exe().map_err(|e| e.to_string())?;
    let mut project_root = exe_path.clone();
    while project_root.pop() {
        if project_root.join("steamcmd").exists() { break; }
    }
    let mut path = project_root.join("steamcmd").join("steamapps").join("workshop").join("content");
    if !game_id.is_empty() { path = path.join(&game_id); }
    std::fs::create_dir_all(&path).ok();
    Command::new("explorer").arg(path).spawn().ok();
    Ok(())
}

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![download_mods, open_mods_folder])
        .run(tauri::generate_context!())
        .expect("erro ao rodar tauri");
}