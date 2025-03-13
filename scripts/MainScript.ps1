# scripts/MainScript.ps1

# Define Paths
$CONFIG_FILE = "$PSScriptRoot\..\config.cfg"
$LOG_FILE = "$PSScriptRoot\..\logs\script.log"
# Target directory for wsl-quick-startup project
$TARGET_DIR="/root/wsl-quick-startup"

# Import helper scripts
. "$PSScriptRoot\Initialize.ps1"
. "$PSScriptRoot\EnsureWSLIsoFile.ps1"
. "$PSScriptRoot\CreateWSLInstance.ps1"
. "$PSScriptRoot\WSLSetup.ps1"
. "$PSScriptRoot\PrepareWSLEnvironment.ps1"
. "$PSScriptRoot\RunAnsible.ps1"
. "$PSScriptRoot\InstallWingetPackages.ps1"
. "$PSScriptRoot\InstallWslVpnToolkit.ps1"

$wingetPackages = @(
  "equalsraf.win32yank"
)

# Initialize Log File
InitializeScript
ReadConfiguration -ConfigFilePath $CONFIG_FILE
ValidateVariables
EnsureWSLInstallation
EnsureWSLIsoFile "$wsl_install_dir\$wsl_instance_name" $wsl_default_iso_url $wsl_iso_file
CreateWSLInstance $wsl_instance_name "$wsl_install_dir\$wsl_instance_name" $wsl_iso_file
PrepareWSLEnvironment
ExecuteAnsible

InstallWingetPackages -PackagesToInstall $wingetPackages
InstallWslVpnToolkit

Write-Host "Script finished successfully."
"Script finished at $(Get-Date)" | Out-File -FilePath $LOG_FILE -Append
exit 0
