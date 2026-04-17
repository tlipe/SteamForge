param (
    [bool]$GenerateEXE = $true,
    [bool]$GenerateNSIS = $false,
    [bool]$CreateZip = $true
)

Write-Host "--- Steam Forge Build System ---" -ForegroundColor Cyan

$ProjectRoot = Get-Location
$ReleaseFolder = "$ProjectRoot\dist_release"
if (Test-Path $ReleaseFolder) { Remove-Item $ReleaseFolder -Recurse -Force }
New-Item -ItemType Directory -Path $ReleaseFolder | Out-Null

Write-Host "[1/2] Compilando Software (Aguarde...)" -ForegroundColor Yellow
npm run tauri build

Write-Host "[2/2] Organizando pacotes..." -ForegroundColor Yellow
$TauriReleasePath = "$ProjectRoot\src-tauri\target\release"

$FoundExe = Get-ChildItem "$TauriReleasePath\*.exe" | Where-Object { $_.Name -notlike "*.pdb" -and $_.Name -notlike "*setup*" } | Select-Object -First 1

if ($GenerateEXE) {
    if ($FoundExe) {
        $ExeFolder = "$ReleaseFolder\SteamForge_Portable"
        New-Item -ItemType Directory -Path $ExeFolder | Out-Null
        
        Copy-Item $FoundExe.FullName -Destination "$ExeFolder\SteamForge.exe"
        Copy-Item "$ProjectRoot\steamcmd" -Destination "$ExeFolder\steamcmd" -Recurse -Force
        
        Write-Host "✓ Executável localizado: $($FoundExe.Name)" -ForegroundColor Green
        
        if ($CreateZip) {
            Compress-Archive -Path "$ExeFolder\*" -DestinationPath "$ReleaseFolder\SteamForge_Portable.zip" -Force
            Write-Host "✓ ZIP Portátil gerado com sucesso." -ForegroundColor Green
        }
    } else {
        Write-Error "ERRO CRÍTICO: Nenhum executável foi encontrado em $TauriReleasePath. O build do Tauri provavelmente falhou."
        exit
    }
}

if ($GenerateNSIS) {
    $NsisPath = "$TauriReleasePath\bundle\nsis"
    if (Test-Path $NsisPath) {
        $Installer = Get-ChildItem "$NsisPath\*.exe" | Select-Object -First 1
        if ($Installer) {
            Copy-Item $Installer.FullName -Destination "$ReleaseFolder\$($Installer.Name)"
            Write-Host "✓ Instalador NSIS copiado." -ForegroundColor Green
        }
    }
}

Write-Host "--- Processo Finalizado! ---" -ForegroundColor Cyan
