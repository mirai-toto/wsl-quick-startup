function New-WslInstance {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$hostname,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$installDir,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$rootfsTar,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$cloudInitFile,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$logFile
  )

  $fullInstallDir = Join-Path $installDir $hostname

  Write-Host "🔍 Checking if WSL instance '$hostname' exists..."
  wsl.exe -d $hostname -- echo "Already exists." > $null 2>&1

  if ($LASTEXITCODE -ne 0) {
    Write-Host "🚧 Instance not found. Creating '$hostname'..."
    Write-Host "📦 Importing with cloud-init..."

    & wsl.exe --import $hostname $full_installDir $rootfsTar --version 2 --cloud-init $cloudInitFile

    if ($LASTEXITCODE -ne 0) {
      Write-Host "❌ Failed to create WSL instance." -ForegroundColor Red
      "[$(Get-Date)] ❌ Error: Failed to create '$hostname'" | Out-File -Append -FilePath $logFile
      exit 1
    }

    Write-Host "✅ WSL instance '$hostname' created successfully." -ForegroundColor Green
  } else {
    Write-Host "ℹ️ WSL instance '$hostname' already exists." -ForegroundColor Yellow
  }
}
