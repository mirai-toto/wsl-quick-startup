function New-WslInstance {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$wslInstanceName,

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

  $fullInstallDir = Join-Path $installDir $wslInstanceName

  Write-Host "🔍 Checking if WSL instance '$wslInstanceName' exists..."
  wsl.exe -d $wslInstanceName -- echo "Already exists." > $null 2>&1

  if ($LASTEXITCODE -ne 0) {
    Write-Host "🚧 Instance not found. Creating '$wslInstanceName'..."
    Write-Host "📦 Importing with cloud-init..."

    & wsl.exe --import $wslInstanceName $full_installDir $rootfsTar --version 2 --cloud-init $cloudInitFile

    if ($LASTEXITCODE -ne 0) {
      Write-Host "❌ Failed to create WSL instance." -ForegroundColor Red
      "[$(Get-Date)] ❌ Error: Failed to create '$wslInstanceName'" | Out-File -Append -FilePath $logFile
      exit 1
    }

    Write-Host "✅ WSL instance '$wslInstanceName' created successfully." -ForegroundColor Green
  } else {
    Write-Host "ℹ️ WSL instance '$wslInstanceName' already exists." -ForegroundColor Yellow
  }
}
