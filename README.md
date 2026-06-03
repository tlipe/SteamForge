# Steam Forge

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/tlipe/steamforge/actions)
[![License](https://img.shields.io/badge/license-MIT-blue)](https://github.com/tlipe/steamforge/blob/main/LICENSE)
[![Rust](https://img.shields.io/badge/Rust-1.70+-orange)](https://www.rust-lang.org/)
[![Typescript](https://img.shields.io/badge/Typescript-5.0+-blue)](https://www.typescriptlang.org/)
[![Tauri](https://img.shields.io/badge/Tauri-framework-lightgrey)](https://tauri.app/)
[![Vite](https://img.shields.io/badge/Vite-bundler-purple)](https://vitejs.dev/)
[![Download Latest Release](https://img.shields.io/badge/Download-Release-blue)](https://github.com/tlipe/steamforge/releases/latest)

---

## Overview

**Steam Forge** is a desktop application that enables users to download Steam mods without requiring login credentials. It is engineered with **Rust** for backend performance and integrates **Vite**, **Tauri**, **Roact**, and **TypeScript** for a modern, responsive frontend. The system supports parallel downloads via multi-threading, ensuring efficiency and speed.

---

## Key Features

- **No Login Required**  
  Download mods directly without Steam account authentication.

- **Parallel Downloads**  
  Multi-threaded system for simultaneous downloads.

- **Rust Backend**  
  High-performance backend ensuring stability and speed.

- **Modern Frontend**  
  Built with Vite, Tauri, Roact, and TypeScript for a lightweight UI.

- **Flexible Mod Management**  
  Copy mod IDs to download multiple mods into a dedicated folder. Some mods are properly named, while others may remain unnamed due to internal SteamCMD limitations.

---

## Installation

<details>
<summary>Step-by-Step Guide</summary>

1. Clone the repository:  
   ```bash
   git clone https://github.com/yourusername/steamforge.git
   ```

2. Navigate to the project directory:  
   ```bash
   cd steamforge
   ```

3. Install dependencies:  
   ```bash
   npm install
   ```

4. Build the project:  
   ```bash
   npm run build
   ```

5. Run the application:  
   ```bash
   npm run tauri dev
   ```
</details>

---

## Usage

- Copy the **mod ID** from Steam Workshop.  
- Paste it into the application interface.  
- Initiate the download process.  
- Mods will be stored in the designated **mods folder**.  

> Note: Some mods may appear unnamed due to SteamCMD internal issues.
