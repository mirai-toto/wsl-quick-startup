# EnsureWSLIsoFile.ps1

function EnsureWSLIsoFile {
  param (
    [string]$install_dir,
    [string]$iso_url,
    [string]$iso_file
  )

  # Create installation directory if it doesn't exist 📁
  if (!(Test-Path $install_dir)) {
    try {
      New-Item -ItemType Directory -Path $install_dir -Force | Out-Null
      Write-Host "Installation directory created: $install_dir"
    } catch {
      Write-Host "Failed to create installation directory: $install_dir"
      "Error: Failed to create install_dir" | Out-File -FilePath $LOG_FILE -Append
      exit 1
    }
  } else {
    Write-Host "Installation directory already exists: $install_dir"
  }

  # Check if ISO file exists 💿
  if (!(Test-Path $iso_file)) {
    if (-not $iso_url) {
      Write-Host "ISO file does not exist and ISO URL is not specified."
      "Error: iso_file not found and iso_url not set" | Out-File -FilePath $LOG_FILE -Append
      exit 1
    }

    Write-Host "Downloading ISO file from $iso_url..."
    try {
      Invoke-WebRequest -Uri $iso_url -OutFile $iso_file -ErrorAction Stop
    } catch {
      Write-Host "Failed to download ISO file."
      "Error: Failed to download iso_file" | Out-File -FilePath $LOG_FILE -Append
      exit 1
    }

    $fileInfo = Get-Item $iso_file
    if ($fileInfo.Length -eq 0) {
      Write-Host "Failed to download ISO file: File is empty. Please check the ISO image URL: $iso_url"
      "Error: ISO file is empty." | Out-File -FilePath $LOG_FILE -Append
      exit 1
    }

    Write-Host "Downloaded ISO file to: $iso_file"
  } else {
    Write-Host "ISO file already exists: $iso_file"
  }
}
