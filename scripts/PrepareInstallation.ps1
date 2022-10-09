# PrepareInstallation.ps1

function PrepareInstallation {
    # Create installation directory if it doesn't exist
    if (!(Test-Path $install_dir)) {
        try {
            New-Item -ItemType Directory -Path $install_dir -Force | Out-Null
            Write-Host "Installation directory created: $install_dir"
        } catch {
            Write-Host "Failed to create installation directory $install_dir."
            "Error: Failed to create install_dir" | Out-File -FilePath $LOG_FILE -Append
            exit 1
        }
    } else {
        Write-Host "Installation directory already exists: $install_dir"
    }

    # Check if iso_file exists
    if (!(Test-Path $iso_file)) {
        if (-not $default_iso_url) {
            Write-Host "ISO file does not exist and default ISO URL is not specified."
            "Error: iso_file not found and default_iso_url not set" | Out-File -FilePath $LOG_FILE -Append
            exit 1
        }
        Write-Host "Downloading ISO file from $default_iso_url..."
        try {
            Invoke-WebRequest -Uri $default_iso_url -OutFile $iso_file -ErrorAction Stop
        } catch {
            Write-Host "Failed to download ISO file."
            "Error: Failed to download iso_file" | Out-File -FilePath $LOG_FILE -Append
            exit 1
        }

        # Check if the ISO file is not empty
        $fileInfo = Get-Item $iso_file
        if ($fileInfo.Length -eq 0) {
            Write-Host "Failed to download ISO file: File is empty."
            "Error: ISO file is empty" | Out-File -FilePath $LOG_FILE -Append
            exit 1
        }
        Write-Host "Downloaded ISO file to $iso_file."
    } else {
        Write-Host "ISO file already exists: $iso_file"
    }
}
