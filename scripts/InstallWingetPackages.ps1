function InstallWingetPackages {
  param (
    [string[]]$PackagesToInstall
  )

  Write-Host "Installing packages using winget..."

  # Check if winget is installed
  if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget is not installed. Please install winget first."
    "Error: winget not installed" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }

  foreach ($packageId in $PackagesToInstall) {
    $packageId = $packageId.Trim()
    Write-Host "Processing package: $packageId"

    # Check if package is already installed
    $isInstalled = winget list --id $packageId -q
    if ($isInstalled) {
      Write-Host "Package $packageId is already installed."
      continue
    }

    # Install the package
    try {
      winget install --id $packageId -e --accept-package-agreements --accept-source-agreements -h
      if ($LASTEXITCODE -ne 0) {
        throw "winget failed with exit code $LASTEXITCODE"
      }
      Write-Host "Package $packageId installed successfully."
    } catch {
      Write-Host "Failed to install package $packageId."
      "Error: Failed to install package $packageId" | Out-File -FilePath $LOG_FILE -Append
      exit 1
    }
  }
}
