function Convert-CloudInitTemplate {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]  
    [string]$templatePath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]  
    [string]$configPath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]  
    [string]$outputPath
  )

  $pythonDir = Join-Path $PSScriptRoot "..\python"
  $venvPath = Join-Path $pythonDir ".venv"
  $venvPython = Join-Path $venvPath "Scripts\python.exe"

  if (-not (Test-Path $venvPython)) {
    Write-Host "📦 Creating virtual environment..."
    uv venv $venvPath
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to create virtual environment"
    }
  }

  Write-Host "📦 Installing Python dependencies..."
  Push-Location $pythonDir
  uv pip install --requirements pyproject.toml
  Pop-Location
  if ($LASTEXITCODE -ne 0) {
    throw "Failed to install Python dependencies"
  }
  
  Write-Host "📄 Rendering cloud-init file from template..."
  & $venvPython (Join-Path $pythonDir "render_template.py") $templatePath $configPath $outputPath

  if ($LASTEXITCODE -ne 0) {
    throw "Cloud-init rendering failed with exit code $LASTEXITCODE"
  }

  Write-Host "✅ Cloud-init file rendered successfully to: $outputPath"
}
