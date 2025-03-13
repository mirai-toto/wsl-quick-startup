# InstallWslVpnToolkit.ps1

. "$PSScriptRoot\EnsureWSLIsoFile.ps1"
. "$PSScriptRoot\CreateWSLInstance.ps1"

$vpn_toolkit_url = "https://github.com/sakai135/wsl-vpnkit/releases/download/$vpn_toolkit_version/wsl-vpnkit.tar.gz"
$UserProfile = $env:USERPROFILE
$vpn_toolkit_file = Join-Path $UserProfile "Downloads\wsl-vpnkit.tar.gz"

function InstallWslVpnToolkit() {
  EnsureWSLIsoFile "$wsl_install_dir\wsl-vpnkit" $vpn_toolkit_url $vpn_toolkit_file
  CreateWSLInstance "wsl-vpnkit" "$wsl_install_dir\wsl-vpnkit" $vpn_toolkit_file

  Write-Host "Setting up systemd service in the distro..."
  $ServiceSetupCommand = @"
  wsl.exe -d wsl-vpnkit --cd /app cat /app/wsl-vpnkit.service | sudo tee /etc/systemd/system/wsl-vpnkit.service
  sudo systemctl enable wsl-vpnkit
  sudo systemctl start wsl-vpnkit
"@

  # Execute commands in wsl-vpnkit distro
  $wsl_output = wsl.exe -d $wsl_instance_name -- bash -c "$ServiceSetupCommand" 2>&1
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to setup systemd service in WSL-VPNKit."
    Write-Host $wsl_output
    exit 1
  }

  Write-Host "WSL-VPNKit installed and started successfully."
}
