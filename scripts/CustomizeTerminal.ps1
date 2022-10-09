# CustomizeTerminal.ps1

function installFont {
  Write-Host "Downloading font archive..."
  try {
    Invoke-WebRequest -Uri $font_url -OutFile "downloaded_font.zip" -ErrorAction Stop
  }
  catch {
    Write-Host "Failed to download font archive."
    "Error: Failed to download font" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }

  Write-Host "Extracting font archive..."
  try {
    Expand-Archive -Path "downloaded_font.zip" -DestinationPath "$env:TEMP\downloaded_font" -Force
  }
  catch {
    Write-Host "Failed to extract font archive."
    "Error: Failed to extract font" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }

  Write-Host "Installing font..."
  try {
    Copy-Item -Path "$env:TEMP\downloaded_font\*.*" -Destination "C:\Windows\Fonts" -Force
    New-ItemProperty -Path $fontRegistryPath -Name $font_name -PropertyType String -Value $font_file -Force | Out-Null
    Write-Host "Font $font_name installed successfully."
  }
  catch {
    Write-Host "Failed to install font."
    "Error: Failed to install font" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }
}

function CustomizeTerminal {
  if ($customize_terminal -ne "true") {
    Write-Host "Font installation is disabled."
    $response = Read-Host "Do you want to update the terminal? (y/n)"
    if ($response -ne "y") {
      return
    }
    $customize_terminal = "true"
    return
  }
  # Download and install font if required
  Write-Host "Font installation is enabled."

  # Check if font is already installed
  $fontRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
  $fontInstalled = Get-ItemProperty -Path $fontRegistryPath | Select-Object -Property * | Where-Object { $_.PSObject.Properties.Name -eq $font_name }

  if ($fontInstalled) {
    Write-Host "Font $font_name is already installed."
  }
  else {
    installFont
  }

  if ($update_windows_terminal_settings -eq "true") {
    Write-Host "Updating WSL settings to use $font_name..."
    wsl.exe -d $distro_name -- sh -c "chmod +x $target_dir/utils/update_wsl_settings.sh"
    wsl.exe -d $distro_name -- sh -c "bash $target_dir/utils/update_wsl_settings.sh '$distro_name' '$font_name' '$use_acrylic' $opacity $windows_terminal_settings"
    if ($LASTEXITCODE -ne 0) {
      Write-Host "Failed to update WSL settings."
      "Error: Failed to update WSL settings" | Out-File -FilePath $LOG_FILE -Append
      exit 1
    }
    Write-Host "WSL settings updated successfully."
  }
}
