function Install-WingetPackages {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]]$packagesToInstall,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$logFile
  )

  Write-Host "📦 Installing packages using winget..."

  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ winget is not installed. Please install it first." -ForegroundColor Red
    "[$(Get-Date)] ❌ winget not installed" | Out-File -FilePath $logFile -Append
    throw "winget not installed"
  }

  foreach ($packageId in $packagesToInstall) {
    $pkg = $packageId.Trim()
    Write-Host "🔍 Checking package: $pkg"

    $alreadyInstalled = winget list --id $pkg -q | Select-String $pkg
    if ($alreadyInstalled) {
      Write-Host "✅ $pkg is already installed."
      continue
    }

    Write-Host "⬇️ Installing $pkg..."
    winget install --id $pkg -e --accept-package-agreements --accept-source-agreements -h

    if ($LASTEXITCODE -ne 0) {
      Write-Host "❌ Failed to install $pkg" -ForegroundColor Red
      "[$(Get-Date)] ❌ Failed to install $pkg (code $LASTEXITCODE)" | Out-File -FilePath $logFile -Append
      throw "winget failed for $pkg"
    }

    Write-Host "✅ $pkg installed successfully."
  }
}
