# Ensure-WslIsoFile

function Ensure-WslIsoFile {
  param (
    [string]$installDir,
    [string]$isoUrl,
    [string]$isoFile,
    [string]$logFile
  )

  # 📁 Create install dir if needed
  if (!(Test-Path $installDir)) {
    try {
      New-Item -ItemType Directory -Path $installDir -Force | Out-Null
      Write-Host "📁 Created installation directory: $installDir"
    } catch {
      Write-Host "❌ Failed to create installation directory: $installDir"
      "[$(Get-Date)] ❌ Failed to create installDir" | Out-File -FilePath $logFile -Append
      throw "Failed to create installation directory"
    }
  } else {
    Write-Host "📁 Installation directory exists: $installDir"
  }

  # 💿 Check ISO
  if (!(Test-Path $isoFile)) {
    if (-not $isoUrl) {
      Write-Host "❌ ISO file not found and no download URL provided."
      "[$(Get-Date)] ❌ isoFile not found and isoUrl not set" | Out-File -FilePath $logFile -Append
      throw "isoFile missing and isoUrl undefined"
    }

    Write-Host "🌐 Downloading ISO from $isoUrl..."
    try {
      Invoke-WebRequest -Uri $isoUrl -OutFile $isoFile -ErrorAction Stop
    } catch {
      Write-Host "❌ Failed to download ISO file."
      "[$(Get-Date)] ❌ Failed to download isoFile" | Out-File -FilePath $logFile -Append
      throw "Failed to download ISO file"
    }

    $fileInfo = Get-Item $isoFile
    if ($fileInfo.Length -eq 0) {
      Write-Host "❌ Downloaded ISO file is empty. Check URL: $isoUrl"
      "[$(Get-Date)] ❌ ISO file is empty" | Out-File -FilePath $logFile -Append
      throw "Downloaded ISO file is empty"
    }

    Write-Host "✅ ISO downloaded: $isoFile"
  } else {
    Write-Host "💿 ISO file already exists: $isoFile"
  }
}
