function IsFeatureEnabled {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$featureName
  )

  $result = dism.exe /online /Get-FeatureInfo /featureName:$featureName | Select-String "State : Enabled"
  return $result -ne $null
}

function EnableWindowsFeature {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$featureName,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$logFile
  )

  if (IsFeatureEnabled -featureName $featureName) {
    Write-Output "✅ $featureName is already enabled. Skipping."
    return $true
  }

  Write-Output "🛠️ Enabling $featureName..."
  dism.exe /online /enable-feature /featureName:$featureName /all /norestart

  if ($LASTEXITCODE -ne 0) {
    "❌ Failed to enable $featureName" | Tee-Object -FilePath $logFile -Append
    return $false
  }

  Write-Output "🎯 $featureName enabled successfully."
  return $true
}

function UpdateWSLVersion {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$logFile
  )

  Write-Output "⬆️ Attempting to update WSL..."
  wsl.exe --update

  if ($LASTEXITCODE -ne 0) {
    "💥 WSL update failed!" | Tee-Object -FilePath $logFile -Append
    return $false
  }

  Write-Output "✨ WSL is up to date!"
  return $true
}

function CheckWSLIsInstalled {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$logFile
  )

  Write-Output "🔎 Checking if WSL is installed..."
  try {
    wsl.exe --status | Out-Null
    Write-Output "📦 WSL is installed."
    return $true
  } catch {
    "🚫 WSL not found on the system." | Tee-Object -FilePath $logFile -Append
    return $false
  }
}

function Setup-WSL {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$logFile
  )

  Write-Output "🚀 Starting WSL setup..."

  if (-not (CheckWSLIsInstalled -logFile $logFile)) {
    throw "⛔ WSL is not installed."
  }

  if (-not (UpdateWSLVersion -logFile $logFile)) {
    throw "⛔ Failed to update WSL."
  }

  if (-not (EnableWindowsFeature -featureName "Microsoft-Windows-Subsystem-Linux" -logFile $logFile)) {
    throw "⛔ Failed to enable Microsoft-Windows-Subsystem-Linux."
  }

  if (-not (EnableWindowsFeature -featureName "VirtualMachinePlatform" -logFile $logFile)) {
    throw "⛔ Failed to enable VirtualMachinePlatform."
  }

  Write-Output "🎉 All done! WSL is ready to use."
}
