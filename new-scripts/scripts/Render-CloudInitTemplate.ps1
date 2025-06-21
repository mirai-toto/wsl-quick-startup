function Render-CloudInitTemplate {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]  
    [string]$templatePath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]  
    [string]$configPath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]  
    [string]$outputPath,
  )

  Write-Host "📄 Rendering cloud-init file from template..."

  python "$PSScriptRoot\python\render_template.py" $templatePath $configPath $outputPath

  if ($LASTEXITCODE -ne 0) {
    throw "Cloud-init rendering failed with exit code $LASTEXITCODE"
  }

  Write-Host "✅ Cloud-init file rendered successfully to: $outputPath"
}
