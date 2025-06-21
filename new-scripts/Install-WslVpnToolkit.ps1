# Install-WslVpnToolkit.ps1

. "$PSScriptRoot\Ensure-WslIsoFile.ps1"
. "$PSScriptRoot\New-WslInstance.ps1"

function Install-WslVpnToolkit {
  param (
    [string]$wslInstallDir,
    [string]$vpnToolkitUrl,
    [string]$logFile
  )

  $distroName = "wsl-vpnkit"
  $installDir = Join-Path $wslInstallDir $distroName
  $vpnToolkitFile = Join-Path $env:USERPROFILE "Downloads\wsl-vpnkit.tar.gz"

  # Ensure ISO file exists
  Ensure-WslIsoFile `
    -installDir $installDir `
    -isoUrl     $vpnToolkitUrl `
    -isoFile    $vpnToolkitFile `
    -logFile    $logFile

  # Create WSL instance
  New-WslInstance `
    -wslInstanceName $distroName `
    -installDir      $wslInstallDir `
    -rootfsTar       $vpnToolkitFile `
    -cloudInitFile   $null `
    -logFile         $logFile

  # Setup systemd service
  Write-Host "⚙️ Setting up systemd service in the distro..."
  $serviceCommand = @"
cat /app/wsl-vpnkit.service | sudo tee /etc/systemd/system/wsl-vpnkit.service
sudo systemctl enable wsl-vpnkit
sudo systemctl start wsl-vpnkit
"@ -join "`n"

  $wslOutput = wsl.exe -d $distroName -- bash -c "$serviceCommand" 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to setup systemd service in $distroName."
    Write-Host $wslOutput
    "[$(Get-Date)] ❌ Failed to setup systemd service in $distroName`n$wslOutput" | Out-File -FilePath $logFile -Append
    return $false
  }

  Write-Host "✅ $distroName installed and started successfully."
  return $true

}
