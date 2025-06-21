# Define paths
$configFile = Join-Path $PSScriptRoot "config.json"
$logDir     = Join-Path $PSScriptRoot "logs"
$logFile    = Join-Path $logDir "script.log"

# Expand and parse config
$config = ([Environment]::ExpandEnvironmentVariables((Get-Content $configFile -Raw)) -replace '\\', '/') | ConvertFrom-Json

# Import helper scripts
. "$PSScriptRoot\scripts\Install-WingetPackages.ps1"
. "$PSScriptRoot\scripts\Initialize-WSL.ps1"
. "$PSScriptRoot\scripts\Ensure-WslIsoFile.ps1"
. "$PSScriptRoot\scripts\Convert-CloudInitTemplate.ps1"
. "$PSScriptRoot\scripts\New-WslInstance.ps1"
. "$PSScriptRoot\scripts\Install-WslVpnToolkit.ps1"

# Winget packages dependencies
$wingetPackages = @(
  "equalsraf.win32yank",
  "Python.Python.3.13"
)

# 📁 Create logs directory if needed
if (-not (Test-Path $logDir)) {
  New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

# 🕒 Initialize log
"Script started at $(Get-Date)" | Out-File -FilePath $logFile

# 🛡️ Check admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
  [Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "❌ This script must be run as Administrator." -ForegroundColor Red
  exit 1
}

# 📦 Install Winget packages
try {
  Install-WingetPackages -packagesToInstall $wingetPackages
}
catch {
  Write-Host "❌ Winget package installation failed: $_" -ForegroundColor Red
  "[$(Get-Date)] ❌ Winget package install error: $_" | Out-File -FilePath $logFile -Append
  exit 1
}

# ⚙️ Setup WSL
try {
  Initialize-WSL -logFile $logFile
}
catch {
  Write-Host "❌ WSL installation failed: $_" -ForegroundColor Red
  "[$(Get-Date)] ❌ WSL installation error: $_" | Out-File -FilePath $logFile -Append
  exit 1
}

# 💿 Ensure ISO file exists
try {
  Ensure-WslIsoFile `
    -installDir  $config.wslInstallDir `
    -isoUrl      $config.wslDefaultIsoUrl `
    -isoFile     $config.wslIsoFile
}
catch {
  Write-Host "❌ ISO file setup failed: $_" -ForegroundColor Red
  "[$(Get-Date)] ❌ ISO file setup error: $_" | Out-File -FilePath $logFile -Append
  exit 1
}

# 📝 Render cloud-init template
try {
  Convert-CloudInitTemplate `
    -templatePath  (Join-Path $PSScriptRoot "cloud-init.template.yaml") `
    -configPath    $configFile `
    -outputPath    (Join-Path $env:TEMP "cloud-init.generated.yaml")
}
catch {
  Write-Host "❌ Failed to render cloud-init template: $_" -ForegroundColor Red
  "[$(Get-Date)] ❌ Cloud-init render exception: $_" | Out-File -FilePath $logFile -Append
  exit 1
}

# 🐧 Create WSL instance
try {
  New-WslInstance `
    -hostname        $config.hostname `
    -installDir      $config.wslInstallDir `
    -rootfsTar       $config.wslIsoFile `
    -cloudInitFile   $config.wslCloudInitFile
}
catch {
  Write-Host "❌ Failed to create WSL instance: $_" -ForegroundColor Red
  "[$(Get-Date)] ❌ Exception: $_" | Out-File -FilePath $logFile -Append
  exit 1
}

# 🛠️ Optional: Install WSL VPN Toolkit
try {
  Install-WslVpnToolkit `
    -wslInstallDir $config.wslInstallDir `
    -vpnToolkitUrl $config.vpnToolkitUrl
}
catch {
  Write-Host "⚠️ WSL VPN Toolkit install failed, continuing..." -ForegroundColor Yellow
  "[$(Get-Date)] ❌ VPN Toolkit install exception: $_" | Out-File -FilePath $logFile -Append
}

# ✅ Done
"Script finished at $(Get-Date)" | Out-File -FilePath $logFile -Append
Write-Host "✅ Script finished successfully."
exit 0
