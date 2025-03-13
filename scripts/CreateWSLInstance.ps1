# CreateWSLInstance.ps1

function CreateWSLInstance {
  param (
    [string]$distro_name,
    [string]$install_dir,
    [string]$iso_file
  )

  Write-Host "Checking if WSL instance '$distro_name' exists..."
  wsl.exe -d $distro_name -- echo "WSL instance already exists." > $null 2>&1

  if ($LASTEXITCODE -ne 0) {
    Write-Host "WSL instance does not exist. Creating now..."
    wsl.exe --import $distro_name "$install_dir\$distro_name" $iso_file --version 2

    if ($LASTEXITCODE -ne 0) {
      Write-Host "Failed to create WSL instance."
      "Error: Failed to create WSL instance" | Out-File -FilePath $LOG_FILE -Append
      exit 1
    }

    Write-Host "WSL instance '$distro_name' created successfully."
  } else {
    Write-Host "WSL instance '$distro_name' already exists."
  }
}
