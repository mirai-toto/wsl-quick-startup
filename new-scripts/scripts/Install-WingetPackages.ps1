function Install-WingetPackages {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string[]]$packagesToInstall
  )

  Write-Host "📦 Installing packages using winget..."

  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "❌ winget is not installed. Please install it first." -ForegroundColor Red
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
      throw "winget failed for $pkg with exit code $LASTEXITCODE"
    }

    Write-Host "✅ $pkg installed successfully."
  }
}
