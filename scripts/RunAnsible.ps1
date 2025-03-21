# RunAnsible.ps1

function ExecuteAnsible {
  Write-Host "Executing ansible-playbook inside WSL..."
  $runAnsibleScriptWSL = "$TARGET_DIR/utils/run_ansible.sh"

  wsl.exe -d $wsl_instance_name -- bash "$runAnsibleScriptWSL"
  $exitCode = $LASTEXITCODE

  if ($exitCode -eq 100) {
    Write-Host "Reboot required. Restarting WSL..."
    wsl.exe --shutdown
    Start-Sleep -Seconds 5
  } elseif ($exitCode -ne 0) {
    Write-Host "Ansible playbook failed with exit code $exitCode."
    "Error: Ansible playbook failed" | Out-File -FilePath $LOG_FILE -Append
    exit 1
  } else {
    Write-Host "Ansible playbook executed successfully."
  }
}
