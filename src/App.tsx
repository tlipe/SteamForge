import { useState, useEffect, useRef } from "react";
import { invoke } from "@tauri-apps/api/tauri";
import { listen } from "@tauri-apps/api/event";
import "./style.css";
// @ts-ignore
import folderIcon from "../assets/foldericon.png";

function App() {
  const [gameId, setGameId] = useState(() => localStorage.getItem("sf_game") || "");
  const [links, setLinks] = useState(() => localStorage.getItem("sf_links") || "");
  const [status, setStatus] = useState("");
  const [progress, setProgress] = useState("");
  const [logs, setLogs] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const logEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    localStorage.setItem("sf_game", gameId);
    localStorage.setItem("sf_links", links);
  }, [gameId, links]);

  useEffect(() => {
    const unLog = listen<string>("download-log", (e) => setLogs(p => [...p.slice(-15), e.payload]));
    const unProg = listen<string>("queue-progress", (e) => setProgress(e.payload));
    return () => { unLog.then(f => f()); unProg.then(f => f()); };
  }, []);

  useEffect(() => { logEndRef.current?.scrollIntoView({ behavior: "smooth" }); }, [logs]);

  async function openFolder() {
    try { await invoke("open_mods_folder", { gameId }); } catch (e) { alert(e); }
  }

  async function start() {
    if (!gameId || !links) return setStatus("Preencha os campos!");
    setLoading(true);
    setLogs(["Aguardando SteamCMD..."]);
    try {
      await invoke("download_mods", { gameId, items: links.split("\n") });
      setStatus("✓ Download concluído!");
      setProgress("");
    } catch (e) { setStatus(`Erro: ${e}`); } finally { setLoading(false); }
  }

  return (
    <div className="container">
      <div className="header-row">
        <h1 className="title">Steam Forge</h1>
        <button className="folder-btn" onClick={openFolder} title="Abrir pasta de downloads">
          <img src={folderIcon} className="folder-img-icon" alt="Folder" />
          <span className="folder-text">ABRIR DOWNLOADS</span>
        </button>
      </div>
      
      <div className="input-group">
        <label>Steam Game ID</label>
        <input value={gameId} onChange={e => setGameId(e.target.value)} placeholder="Ex: 294100" disabled={loading} />
      </div>
      
      <div className="input-group">
        <label>Workshop Links / IDs</label>
        <textarea value={links} onChange={e => setLinks(e.target.value)} placeholder="Cole aqui os links ou IDs..." disabled={loading} />
      </div>
      
      <button className="main-btn" onClick={start} disabled={loading}>{loading ? "BAIXANDO..." : "BAIXAR MODS"}</button>
      
      {progress && <div className="queue-badge">{progress}</div>}
      
      <div className="console-log">
        {logs.length === 0 && <div className="log-line" style={{opacity: 0.2}}>Console aguardando execução...</div>}
        {logs.map((l, i) => <div key={i} className="log-line">{l}</div>)}
        <div ref={logEndRef} />
      </div>
      
      {status && <div className="status">{status}</div>}
    </div>
  );
}
export default App;