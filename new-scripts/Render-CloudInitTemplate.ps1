# Render-CloudInitTemplate.ps1

function Render-CloudInitTemplate {
    param (
      [string]$pythonExe,
      [string]$templatePath,
      [string]$configPath,
      [string]$outputPath,
      [string]$logFile
    )
  
    Write-Host "📄 Rendering cloud-init file from template..."
  
    try {
      & $pythonExe "$PSScriptRoot\python\render_template.py" $templatePath $configPath $outputPath
  
      if ($LASTEXITCODE -ne 0) {
        throw "Cloud-init rendering failed with code $LASTEXITCODE"
      }
    } catch {
      Write-Host "❌ Failed to render cloud-init file: $_" -ForegroundColor Red
      "[$(Get-Date)] ❌ Cloud-init render error: $_" | Out-File -FilePath $logFile -Append
      exit 1
    }
  
    Write-Host "✅ Cloud-init file rendered successfully to: $outputPath"
  }
  