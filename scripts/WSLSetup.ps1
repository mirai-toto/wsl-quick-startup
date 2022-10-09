# WSLSetup.ps1

function CheckWSL {
    Write-Host "Checking if WSL is installed..."
    try {
        wsl.exe --status | Out-Null
        Write-Host "WSL is installed."
    } catch {
        Write-Host "WSL is not installed. Please install it first."
        "Error: WSL not installed" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }
}

function ManageWSLInstance {
    # Check if WSL instance exists
    Write-Host "Checking if WSL instance $distro_name exists..."
    wsl.exe -d $distro_name -- echo "WSL instance already exists." > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WSL instance does not exist. Creating now..."
        wsl.exe --import $distro_name "$install_dir\$distro_name" $iso_file --version 2
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to create WSL instance."
            "Error: Failed to create WSL instance" | Out-File -FilePath $LOG_FILE -Append
            exit 1
        }
        Write-Host "WSL instance $distro_name created successfully."
    } else {
        Write-Host "WSL instance $distro_name already exists."
    }
}
