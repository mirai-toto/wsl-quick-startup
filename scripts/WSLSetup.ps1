# WSLSetup.ps1

function IsFeatureEnabled {
  param (
    [string]$FeatureName
  )

  Write-Host "Checking if feature $FeatureName is enabled..."
  $output = dism.exe /online /Get-FeatureInfo /FeatureName:$FeatureName | Select-String "State : Enabled"
  return $output -ne $null
}

function EnableWindowsFeature {
  param (
    [string]$FeatureName
  )

  if (IsFeatureEnabled -FeatureName $FeatureName) {
    Write-Host "$FeatureName is already enabled."
    return
  }

  Write-Host "Enabling feature $FeatureName..."
  try {
    dism.exe /online /enable-feature /featurename:$FeatureName /all /norestart
    if ($LASTEXITCODE -ne 0) {
      Write-Host "Error: Failed to enable feature $FeatureName."
      "Error: Failed to enable feature $FeatureName" | Out-File -FilePath $LOG_FILE -Append
      exit 1
    }
    Write-Host "Feature $FeatureName enabled successfully."
  } catch {
    Write-Host "Error: Unable to enable feature $FeatureName."
    "Error: Unable to enable feature $FeatureName" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }
}

function UpdateWSLVersion {
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
  EnableWindowsFeature -FeatureName "Microsoft-Windows-Subsystem-Linux"
}

function EnableVirtualMachinePlatform {
  EnableWindowsFeature -FeatureName "VirtualMachinePlatform"
}

function EnsureWSLInstallation {
  CheckWSLIsInstalled

  Write-Host "Ensuring WSL is correctly installed and updated..."

  # Update WSL to the latest version
  UpdateWSLVersion

  # Enable WSL feature
  EnableWSLFeature

  # Enable Virtual Machine Platform
  EnableVirtualMachinePlatform

  Write-Host "WSL setup is complete. Please restart your machine if prompted."
}

function CheckWSLIsInstalled {
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

