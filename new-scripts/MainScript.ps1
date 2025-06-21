# scripts/MainScript.ps1

# Define paths
$configFile = Join-Path $PSScriptRoot "config.json"
$logFile    = Join-Path $PSScriptRoot "logs\script.log"

# Expand environment variables in the config JSON file
$config = [Environment]::ExpandEnvironmentVariables((Get-Content $configFile -Raw)) | ConvertFrom-Json

# Import helper script
. "$PSScriptRoot\New-WslInstance.ps1"
. "$PSScriptRoot\Setup-Wsl.ps1"
. "$PSScriptRoot\Ensure-WslIsoFile.ps1"
. "$PSScriptRoot\Install-WslVpnToolkit.ps1"

# Packages (can be used later)
$wingetPackages = @(
  "equalsraf.win32yank"
)

# Create logs directory if it doesn't exist 📁📝
if (!(Test-Path "$PSScriptRoot\logs")) {
  New-Item -ItemType Directory -Path "$PSScriptRoot\logs" -Force | Out-Null
}

# Initialize Log File 🕒
"Script started at $(Get-Date)" | Out-File -FilePath $logFile

# Check for elevated privileges 🛡️
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
  [Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "❌ This script must be run as Administrator." -ForegroundColor Red
  exit 1
}

try {
  Setup-Wsl -logFile $logFile
}
catch {
  Write-Host "❌ WSL installation failed: $_" -ForegroundColor Red
  "[$(Get-Date)] ❌ WSL installation error: $_" | Out-File -FilePath $logFile -Append
  exit 1
}

try {
  Ensure-WslIsoFile `
    -installDir      $config.wslInstallDir `
    -isoUrl          $config.wslDefaultIsoUrl `
    -isoFile         $config.wslIsoFile `
    -logFile         $logFile
}
catch {
  Write-Host "❌ ISO file setup failed: $_" -ForegroundColor Red
  "[$(Get-Date)] ❌ ISO file setup error: $_" | Out-File -FilePath $logFile -Append
  exit 1
}

try {
  New-WslInstance `
    -hostname $config.hostname `
    -installDir      $config.wslInstallDir `
    -rootfsTar       $config.wslIsoFile `
    -cloudInitFile   $config.wslCloudInitFile `
    -logFile         $logFile
}
catch {
  Write-Host "❌ Failed to create WSL instance: $_" -ForegroundColor Red
  "[$(Get-Date)] ❌ Exception: $_" | Out-File -FilePath $logFile -Append
  exit 1
}

try {
  Install-WslVpnToolkit `
    -wslInstallDir $config.wslInstallDir `
    -vpnToolkitUrl $config.vpnToolkitUrl `
    -logFile       $logFile
}
catch {
  Write-Host "⚠️ WSL VPN Toolkit install failed, continuing..." -ForegroundColor Yellow
  "[$(Get-Date)] ❌ VPN Toolkit install exception: $_" | Out-File -FilePath $logFile -Append
}

# ✅ Finished
"Script finished at $(Get-Date)" | Out-File -FilePath $logFile -Append
Write-Host "✅ Script finished successfully."
exit 0
