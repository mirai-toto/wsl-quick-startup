function Test-WslIsoFile {
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$installDir,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$isoUrl,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$isoFile
  )

  # 📁 Create install dir if needed
  if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "📁 Created installation directory: $installDir"
  } else {
    Write-Host "📁 Installation directory exists: $installDir"
  }

  # 💿 Check ISO
  if (-not (Test-Path $isoFile)) {
    if (-not $isoUrl) {
      throw "ISO file not found and no download URL provided."
    }

    Write-Host "🌐 Downloading ISO from $isoUrl..."
    Invoke-WebRequest -Uri $isoUrl -OutFile $isoFile -ErrorAction Stop

    $fileInfo = Get-Item $isoFile
    if ($fileInfo.Length -eq 0) {
      throw "Downloaded ISO file is empty. Check URL: $isoUrl"
    }

    Write-Host "✅ ISO downloaded: $isoFile"
  } else {
    Write-Host "💿 ISO file already exists: $isoFile"
  }
}
