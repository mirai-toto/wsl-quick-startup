# scripts/MainScript.ps1

# Import helper scripts
. "$PSScriptRoot\Initialize.ps1"
. "$PSScriptRoot\ReadConfiguration.ps1"
. "$PSScriptRoot\ValidateVariables.ps1"
. "$PSScriptRoot\PrepareInstallation.ps1"
. "$PSScriptRoot\WSLSetup.ps1"
. "$PSScriptRoot\FileOperations.ps1"
. "$PSScriptRoot\RunAnsible.ps1"
. "$PSScriptRoot\CustomizeTerminal.ps1"
. "$PSScriptRoot\InstallWingetPackages.ps1"

$wingetPackages = @(
    "equalsraf.win32yank"
)

# Initialize Log File
InitializeScript

CheckWSL
EnsureWSLSetup

ReadConfiguration -ConfigFilePath $CONFIG_FILE -CustomConfigFilePath $CUSTOM_CONFIG_FILE
ValidateVariables
PrepareInstallation
ManageWSLInstance
PrepareWSLEnvironment
ExecuteAnsible
CustomizeTerminal
InstallWingetPackages -PackagesToInstall $wingetPackages

Write-Host "Script finished successfully."
"Script finished at $(Get-Date)" | Out-File -FilePath $LOG_FILE -Append
exit 0
