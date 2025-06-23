function Install-WslVpnToolkit {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$wslInstallDir,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$vpnToolkitUrl
  )

  $distroName = "wsl-vpnkit"
  $installDir = Join-Path $wslInstallDir $distroName
  $vpnToolkitFile = Join-Path $env:USERPROFILE "Downloads\wsl-vpnkit.tar.gz"

  # Test ISO file exists
  Test-WslIsoFile `
    -installDir $installDir `
    -isoUrl     $vpnToolkitUrl `
    -isoFile    $vpnToolkitFile

  # Create WSL instance
  New-WslInstance `
    -hostname       $distroName `
    -installDir     $wslInstallDir `
    -rootfsTar      $vpnToolkitFile `
    -cloudInitFile  $null

  # Setup systemd service
  $serviceCommand = @"
cat /app/wsl-vpnkit.service | sudo tee /etc/systemd/system/wsl-vpnkit.service
sudo systemctl enable wsl-vpnkit
sudo systemctl start wsl-vpnkit
"@

  $wslOutput = wsl.exe -d $distroName -- bash -c "$serviceCommand" 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to setup systemd service in $distroName." -ForegroundColor Red
    Write-Host $wslOutput
    throw "Failed to setup systemd service in $distroName"
  }

  Write-Host "✅ $distroName installed and started successfully."
}
