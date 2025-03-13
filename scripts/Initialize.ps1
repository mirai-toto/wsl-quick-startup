# scripts/Initialize.ps1

# Check for elevated privileges 🛡️
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "This script must be run as an administrator. Please restart the script in an elevated PowerShell session." -ForegroundColor Red
  exit 1
}

function ParseConfigurationFile {
  param (
    [string]$FilePath
  )
  Get-Content $FilePath | ForEach-Object {
    if ($_ -match '^\s*([^#][^=]*)=(.*)$') {
      $var_name = $Matches[1].Trim()
      $var_value = $Matches[2].Trim()

      $expanded_value = [Environment]::ExpandEnvironmentVariables($var_value)
      Set-Variable -Name $var_name -Value $expanded_value -Scope Global
    }
  }
}

function ReadConfiguration {
  param (
    [string]$ConfigFilePath
  )

  if (!(Test-Path $ConfigFilePath)) {
    Write-Host "Configuration file $ConfigFilePath not found."
    "Error: Configuration file not found" | Out-File -FilePath $LogFilePath -Append
    exit 1
  }
  Write-Host "Reading configuration files..."
  ParseConfigurationFile -FilePath $ConfigFilePath
}

function ValidateVariables {
  # Check if essential variables are set ✅
  if (-not $wsl_install_dir) {
    Write-Host "Installation directory not specified in config file."
    "Error: install_dir not set" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }

  if (-not $wsl_iso_file) {
    Write-Host "ISO file path not specified in config file."
    "Error: iso_file not set" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }

  if (-not $wsl_instance_name) {
    Write-Host "WSL Instance name not specified in config file."
    "Error: distro_name not set" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  }
}

function InitializeScript {
  # Create logs directory if it doesn't exist 📁📝
  if (!(Test-Path "$PSScriptRoot\..\logs")) {
    New-Item -ItemType Directory -Path "$PSScriptRoot\..\logs" -Force | Out-Null
  }

  # Initialize Log File 🕒
  "Script started at $(Get-Date)" | Out-File -FilePath $LOG_FILE
}
