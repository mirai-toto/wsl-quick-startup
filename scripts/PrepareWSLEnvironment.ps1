# scripts/PrepareWSLEnvironment.ps1

function PrepareWSLEnvironment {
  # Create target directory inside WSL 📁🐧
  if (-not $TARGET_DIR) {
    Write-Host "Target directory not specified in config file."
    "Error: TARGET_DIR not set" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }
  Write-Host "Creating target directory $TARGET_DIR inside WSL..."
  wsl.exe -d $wsl_instance_name -- mkdir -p $TARGET_DIR
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create target directory inside WSL."
    "Error: Failed to create TARGET_DIR in WSL" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }
  Write-Host "Target directory created."

  # Copy files from Windows host to WSL instance 📤➡️🐧
  Write-Host "Copying files to WSL instance..."
  $projectRoot = "$PSScriptRoot\.."
  $destinationPath = "\\wsl$\$wsl_instance_name\$TARGET_DIR"

  try {
    Copy-Item -Path "$projectRoot\*" -Destination $destinationPath -Recurse -Force -Exclude 'logs', 'scripts'
    Write-Host "Files copied successfully."
  } catch {
    Write-Host "Failed to copy files to WSL instance."
    "Error: Failed to copy files to WSL" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }

  # Convert Windows line endings (CRLF) to Linux format (LF) in WSL 🔄📝
  $convertLineEndingsCommand = "find $TARGET_DIR -type f -exec sed -i 's/\r$//' {} \;"

  wsl.exe -d $wsl_instance_name -- bash -c "$convertLineEndingsCommand"

  if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to convert line endings in WSL."
    "Error: Failed to convert line endings" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  } else {
    Write-Host "Line endings converted successfully."
  }
}
