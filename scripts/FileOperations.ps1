# scripts/FileOperations.ps1

function PrepareWSLEnvironment {
    # Create target directory inside WSL
    if (-not $target_dir) {
        Write-Host "Target directory not specified in config file."
        "Error: target_dir not set" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }
    Write-Host "Creating target directory $target_dir inside WSL..."
    wsl.exe -d $distro_name -- mkdir -p $target_dir
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to create target directory inside WSL."
        "Error: Failed to create target_dir in WSL" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }
    Write-Host "Target directory created."

    # Copy files from Windows host to WSL instance
    Write-Host "Copying files to WSL instance..."
    $projectRoot = "$PSScriptRoot\.."
    $destinationPath = "\\wsl$\$distro_name\$target_dir"

    try {
        Copy-Item -Path "$projectRoot\*" -Destination $destinationPath -Recurse -Force -Exclude 'logs', 'scripts'
        Write-Host "Files copied successfully."
    } catch {
        Write-Host "Failed to copy files to WSL instance."
        "Error: Failed to copy files to WSL" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }

    # Convert line endings in WSL
    $convertLineEndingsCommand = "find $target_dir -type f -exec sed -i 's/\r$//' {} \;"

    wsl.exe -d $distro_name -- bash -c "$convertLineEndingsCommand"

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to convert line endings in WSL."
        "Error: Failed to convert line endings" | Out-File -FilePath $LOG_FILE -Append
        exit 1
    }
}
