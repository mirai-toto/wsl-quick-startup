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
        [string]$ConfigFilePath,
        [string]$CustomConfigFilePath
    )

    if (!(Test-Path $ConfigFilePath)) {
        Write-Host "Configuration file $ConfigFilePath not found."
        "Error: Configuration file not found" | Out-File -FilePath $LogFilePath -Append
        exit 1
    }

    if (!(Test-Path $CustomConfigFilePath)) {
        Write-Host "Custom Configuration file $CustomConfigFilePath not found."
        "Error: Custom Configuration file not found" | Out-File -FilePath $LogFilePath -Append
        exit 1
    }

    Write-Host "Reading configuration files..."
    ParseConfigurationFile -FilePath $ConfigFilePath
    ParseConfigurationFile -FilePath $CustomConfigFilePath
}
