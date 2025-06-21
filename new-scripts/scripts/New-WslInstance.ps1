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

    [string]$cloudInitFile
  )

  $fullInstallDir = Join-Path $installDir $hostname

  Write-Host "🔍 Checking if WSL instance '$hostname' exists..."
  wsl.exe -d $hostname -- echo "Already exists." > $null 2>&1

  if ($LASTEXITCODE -ne 0) {
    Write-Host "🚧 Instance not found. Creating '$hostname'..."

    $importArgs = @(
      "--import", $hostname,
      $fullInstallDir,
      $rootfsTar,
      "--version", "2"
    )

    if ($cloudInitFile -and (Test-Path $cloudInitFile)) {
      Write-Host "📦 Using cloud-init file: $cloudInitFile"
      $importArgs += @("--cloud-init", $cloudInitFile)
    } else {
      Write-Host "⚠️ No valid cloud-init file provided. Skipping cloud-init import."
    }

    & wsl.exe @importArgs

    if ($LASTEXITCODE -ne 0) {
      Write-Host "❌ Failed to create WSL instance." -ForegroundColor Red
      throw "Failed to create WSL instance '$hostname'"
    }

    Write-Host "✅ WSL instance '$hostname' created successfully." -ForegroundColor Green
  } else {
    Write-Host "ℹ️ WSL instance '$hostname' already exists." -ForegroundColor Yellow
  }
}
