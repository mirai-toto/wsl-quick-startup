# WSLSetup.ps1

function UpdateWSL {
    Write-Host "Updating WSL to the latest version..."
    try {
        wsl.exe --update
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: Failed to update WSL."
            "Error: Failed to update WSL" | Out-File -FilePath $LOG_FILE -Append
            exit 1
        }
        Write-Host "WSL updated successfully."
    } catch {
        Write-Host "Error: Unable to update WSL."
        "Error: Unable to update WSL" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }
}

function EnableWSLFeature {
    Write-Host "Enabling WSL feature..."
    try {
        dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: Failed to enable WSL feature."
            "Error: Failed to enable WSL feature" | Out-File -FilePath $LOG_FILE -Append
            exit 1
        }
        Write-Host "WSL feature enabled successfully."
    } catch {
        Write-Host "Error: Unable to enable WSL feature."
        "Error: Unable to enable WSL feature" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }
}

function EnableVirtualMachinePlatform {
    Write-Host "Enabling Virtual Machine Platform feature..."
    try {
        dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Error: Failed to enable Virtual Machine Platform feature."
            "Error: Failed to enable Virtual Machine Platform feature" | Out-File -FilePath $LOG_FILE -Append
            exit 1
        }
        Write-Host "Virtual Machine Platform feature enabled successfully."
    } catch {
        Write-Host "Error: Unable to enable Virtual Machine Platform feature."
        "Error: Unable to enable Virtual Machine Platform feature" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }
}

function EnsureWSLSetup {
    Write-Host "Ensuring WSL is correctly installed and updated..."

    # Update WSL to the latest version
    UpdateWSL

    # Enable WSL feature
    EnableWSLFeature

    # Enable Virtual Machine Platform
    EnableVirtualMachinePlatform

    Write-Host "WSL setup is complete. Please restart your machine if prompted."
}

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
