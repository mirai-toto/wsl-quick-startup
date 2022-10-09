# ValidateVariables.ps1

function ValidateVariables {
    # Check if essential variables are set
    if (-not $install_dir) {
        Write-Host "Installation directory not specified in config file."
        "Error: install_dir not set" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }

    if (-not $iso_file) {
        Write-Host "ISO file path not specified in config file."
        "Error: iso_file not set" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }

    if (-not $distro_name) {
        Write-Host "Distro name not specified in config file."
        "Error: distro_name not set" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }
}
