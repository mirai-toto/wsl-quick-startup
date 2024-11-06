@echo off
setlocal enabledelayedexpansion

REM =====================================================
REM Script to Set Up WSL Instance with Ansible Automation
REM =====================================================

REM Define Variables
set CONFIG_FILE=config.cfg
set LOG_FILE=script.log

REM Initialize Log File
echo Script started at %DATE% %TIME% > %LOG_FILE%

REM Check if WSL is installed
echo Checking if WSL is installed...
wsl.exe --status >NUL 2>&1
if %errorlevel% neq 0 (
    echo WSL is not installed. Please install it first.
    echo Error: WSL not installed >> %LOG_FILE%
    exit /b 1
) else (
    echo WSL is installed.
)

REM Read configuration file
if not exist "%CONFIG_FILE%" (
    echo Configuration file %CONFIG_FILE% not found.
    echo Error: Configuration file not found >> %LOG_FILE%
    exit /b 1
)

echo Reading configuration file...
for /f "tokens=1,* delims=#=" %%a in ('type %CONFIG_FILE% ^| findstr "="') do (
    set var_name=%%a
    set var_value=%%b
    REM Set variable by parsing the value
    for /f "tokens=* delims=" %%i in ('call ./utils/parse_config_line.bat "!var_value!"') do set "!var_name!=%%i"
)

REM Check if essential variables are set
if "%install_dir%"=="" (
    echo Installation directory not specified in config file.
    echo Error: install_dir not set >> %LOG_FILE%
    exit /b 1
)

if "%iso_file%"=="" (
    echo ISO file path not specified in config file.
    echo Error: iso_file not set >> %LOG_FILE%
    exit /b 1
)

if "%distro_name%"=="" (
    echo Distro name not specified in config file.
    echo Error: distro_name not set >> %LOG_FILE%
    exit /b 1
)

REM Create installation directory if it doesn't exist
if not exist "%install_dir%" (
    mkdir "%install_dir%"
    if %errorlevel% neq 0 (
        echo Failed to create installation directory %install_dir%.
        echo Error: Failed to create install_dir >> %LOG_FILE%
        exit /b 1
    )
    echo Installation directory created: %install_dir%
) else (
    echo Installation directory already exists: %install_dir%
)

REM Check if iso_file exists
if not exist "%iso_file%" (
    if "%default_iso_url%"=="" (
        echo ISO file does not exist and default ISO URL is not specified.
        echo Error: iso_file not found and default_iso_url not set >> %LOG_FILE%
        exit /b 1
    )
    echo Downloading ISO file from %default_iso_url%...
    powershell.exe -Command "Invoke-WebRequest %default_iso_url% -OutFile \"%iso_file%\""
    if %errorlevel% neq 0 (
        echo Failed to download ISO file.
        echo Error: Failed to download iso_file >> %LOG_FILE%
        exit /b 1
    )

    REM Check if the ISO file exists
    if not exist "%iso_file%" (
        echo Failed to download ISO file: File does not exist.
        echo Error: ISO file does not exist >> %LOG_FILE%
        exit /b 1
    )
    REM Check if the ISO file is not empty
    for %%A in ("%iso_file%") do if %%~zA EQU 0 (
        echo Failed to download ISO file: File is empty.
        echo Error: ISO file is empty >> %LOG_FILE%
        exit /b 1
    )
    echo Downloaded ISO file to %iso_file%.
) else (
    echo ISO file already exists: %iso_file%
)

REM Check if WSL instance exists
echo Checking if WSL instance %distro_name% exists...
wsl.exe -d %distro_name% -- echo "WSL instance already exists." >NUL 2>&1
if %errorlevel% neq 0 (
    echo WSL instance does not exist. Creating now...
    wsl.exe --import %distro_name% "%install_dir%\%distro_name%" "%iso_file%" --version 2
    if errorlevel 1 (
        echo Failed to create WSL instance.
        echo Error: Failed to create WSL instance >> %LOG_FILE%
        exit /b 1
    )
    echo WSL instance %distro_name% created successfully.
) else (
    echo WSL instance %distro_name% already exists.
)

REM Create target directory inside WSL
if "%target_dir%"=="" (
    echo Target directory not specified in config file.
    echo Error: target_dir not set >> %LOG_FILE%
    exit /b 1
)
echo Creating target directory %target_dir% inside WSL...
wsl.exe -d %distro_name% -- mkdir -p %target_dir%
if %errorlevel% neq 0 (
    echo Failed to create target directory inside WSL.
    echo Error: Failed to create target_dir in WSL >> %LOG_FILE%
    exit /b 1
)
echo Target directory created.

REM Copy files from Windows host to WSL instance
echo Copying files to WSL instance...
xcopy "%~dp0" "\\wsl$\%distro_name%\%target_dir%" /S /E /I /Y >NUL
if %errorlevel% neq 0 (
    echo Failed to copy files to WSL instance.
    echo Error: Failed to copy files to WSL >> %LOG_FILE%
    exit /b 1
)
echo Files copied successfully.

REM ===========================
REM Set Up Proxy in WSL
REM ===========================

if "%http_proxy_wsl%"=="" (
    if "%https_proxy_wsl%"=="" (
        echo No proxy settings provided; proceeding without proxy configuration.
    ) else (
        goto ConfigureProxy
    )
) else (
    goto ConfigureProxy
)
goto AfterProxySetup

:ConfigureProxy
echo Proxy settings provided; configuring proxy inside WSL...

REM Ensure the script is executable
echo Setting execute permissions on setup-apt-proxy.sh...
wsl.exe -d %distro_name% -- chmod +x %target_dir%/utils/setup-apt-proxy.sh
if %errorlevel% neq 0 (
    echo Failed to set execute permissions on setup-apt-proxy.sh.
    echo Error: chmod failed >> %LOG_FILE%
    exit /b 1
)

REM Run the proxy setup script inside WSL
echo Setting up proxy settings inside WSL...
wsl.exe -d %distro_name% -- bash %target_dir%/utils/setup-apt-proxy.sh "%http_proxy_wsl%" "%https_proxy_wsl%"
if %errorlevel% neq 0 (
    echo Failed to execute setup-apt-proxy.sh.
    echo Error: Failed to set up proxy >> %LOG_FILE%
    exit /b 1
)
echo Proxy settings configured inside WSL.

:AfterProxySetup

REM ===========================
REM Execute the Ansible
REM ===========================

REM Install Ansible and jq
echo Installing Ansible and jq inside WSL...
wsl.exe -d %distro_name% -- sudo apt-get update -y
wsl.exe -d %distro_name% -- sudo apt-get install -y ansible jq
if %errorlevel% neq 0 (
    echo Failed to install Ansible and jq.
    echo Error: Failed to install Ansible and jq >> %LOG_FILE%
    exit /b 1
)
echo Ansible and jq installed successfully.

REM Launch Ansible for the first time
echo Launching Ansible playbook...
wsl.exe -d %distro_name% -- sudo ansible-playbook %target_dir%/playbooks/setup-wsl.yaml -i %target_dir%/hosts.ini
if %errorlevel% neq 0 (
    echo Ansible playbook execution failed.
    echo Error: Ansible playbook failed >> %LOG_FILE%
    exit /b 1
)
echo Ansible playbook executed successfully.

REM Restart WSL instance
echo Restarting WSL instance...
wsl.exe --shutdown
if %errorlevel% neq 0 (
    echo Failed to shutdown WSL instance.
    echo Error: Failed to shutdown WSL >> %LOG_FILE%
    exit /b 1
)
echo WSL instance restarted.

REM Relaunch Ansible
echo Relaunching Ansible playbook...
wsl.exe -d %distro_name% -- sudo ansible-playbook %target_dir%/playbooks/setup-wsl.yaml -i %target_dir%/hosts.ini
if %errorlevel% neq 0 (
    echo Ansible playbook re-execution failed.
    echo Error: Ansible playbook re-execution failed >> %LOG_FILE%
    exit /b 1
)
echo Ansible playbook re-executed successfully.

REM Download and install font if required
if /I "%install_font%"=="true" (
    echo Font installation is enabled.
    REM Check if font is already installed
    reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" | findstr /i "%font_name%" >NUL
    if %errorlevel% equ 0 (
        echo Font %font_name% is already installed.
    ) else (
        echo Downloading font archive...
        powershell.exe -Command "Try { Invoke-WebRequest https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/DroidSansMono.zip -OutFile DroidSansMono.zip } Catch { Exit 1 }"
        if %errorlevel% neq 0 (
            echo Failed to download font archive.
            echo Error: Failed to download font >> %LOG_FILE%
            exit /b 1
        )
        echo Extracting font archive...
        powershell.exe -Command "Try { Expand-Archive DroidSansMono.zip -DestinationPath %TEMP%\DroidSansMono -Force } Catch { Exit 1 }"
        if %errorlevel% neq 0 (
            echo Failed to extract font archive.
            echo Error: Failed to extract font >> %LOG_FILE%
            exit /b 1
        )
        echo Installing font...
        xcopy "%TEMP%\DroidSansMono\*.*" "C:\Windows\Fonts" /Y >NUL
        if %errorlevel% neq 0 (
            echo Failed to install font.
            echo Error: Failed to install font >> %LOG_FILE%
            exit /b 1
        )
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "%font_name%" /t REG_SZ /d "DroidSansMNerdFontMono-Regular.otf" /f
        echo Font %font_name% installed successfully.
    )

    if /I "%update_wsl_settings%"=="true" (
        echo Updating WSL settings to use %font_name%...
        wsl.exe -d %distro_name% -- sh -c "chmod +x %target_dir%/playbooks/files/update_wsl_settings.sh"
        wsl.exe -d %distro_name% -- sh -c "bash %target_dir%/playbooks/files/update_wsl_settings.sh \"%distro_name%\" \"%font_name%\" \"%use_acrylic%\" %opacity% %wsl_settings_file%"
        if %errorlevel% neq 0 (
            echo Failed to update WSL settings.
            echo Error: Failed to update WSL settings >> %LOG_FILE%
            exit /b 1
        )
        echo WSL settings updated successfully.
    )
) else (
    echo Font installation is disabled.
)

echo Script finished successfully.
echo Script finished at %DATE% %TIME% >> %LOG_FILE%
exit /b 0
