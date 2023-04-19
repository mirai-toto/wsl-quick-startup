@echo off

setlocal enabledelayedexpansion

REM Read configuration file
set config_file=config.txt
for /f "tokens=1,* delims=#=" %%a in ('type %config_file% ^| findstr "="') do (
    set var_name=%%a
    set var_value=%%b
    REM Set variable
    for /f %%i in ('call ./utils/parse_config_line.bat "!var_value!"') do set "!var_name!=%%i"
)

REM Create installation directory if it doesn't exist
if not exist "%install_dir%" (
    mkdir "%install_dir%"
    echo "Installation directory created: %install_dir%"
)

REM Check if WSL instance exists
wsl.exe -d %distro_name% -- echo "WSL instance already exists."

if %errorlevel% equ 0 (
    echo "WSL instance already exists."
) else (
    echo "WSL instance does not exist. Creating now..."
    wsl.exe --import %distro_name% %install_dir%\%distro_name% %iso_file% --version 2
    wsl.exe -d %distro_name% -- echo "WSL instance created successfully."
)
echo "Installation finished."

REM Create target directory if it does not exist
echo "Creating target directory..."
wsl.exe -d %distro_name% -- mkdir -p %target_dir%

REM Copy file or folder from Windows host to WSL instance
echo "Copying file or folder from Windows host to WSL instance..."
xcopy "%~dp0" "\\wsl$\%distro_name%\%target_dir%" /S /E /I /Y
echo "File or folder copied successfully."

REM Install Ansible and jq
echo "Installing Ansible..."
wsl.exe -d %distro_name% -- sudo apt-get update
wsl.exe -d %distro_name% -- sudo apt-get install -y ansible
wsl.exe -d %distro_name% -- sudo apt-get install -y jq
echo "Ansible installed successfully."

REM Launch Ansible for the first time
echo "Launching Ansible for the first time..."
wsl.exe -d %distro_name% -- sudo ansible-playbook %target_dir%/playbooks/setup-wsl.yaml -i %target_dir%/hosts.ini

REM Restart WSL instance
echo "Restarting WSL instance..."
wsl.exe --shutdown

REM Relaunch Ansible
echo "Relaunching Ansible..."
wsl.exe -d %distro_name% -- sudo ansible-playbook %target_dir%/playbooks/setup-wsl.yaml -i %target_dir%/hosts.ini

REM Download DroidSansMono.zip, extract it and install the font
if "%install_font%"=="true" (
REM Check if font is installed
    reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" | find /i "DroidSansMNerdFontMono-Regular.otf" && (
        echo "Font already installed."
    ) || (
        REM Download font archive
        echo "Downloading font archive..."
        powershell.exe -Command "Invoke-WebRequest https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/DroidSansMono.zip -OutFile DroidSansMono.zip"

        REM Extract font archive
        echo "Extracting font archive..."
        powershell.exe -Command "Expand-Archive DroidSansMono.zip -DestinationPath C:\Windows\Fonts -Force"

        REM Install font
        echo "Installing font..."
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Droid Sans Mono for Powerline" /t REG_SZ /d "DroidSansMNerdFontMono-Regular.otf" /f
    )

    if "%update_wsl_settings%"=="true" (
        REM Use jq to update the profile
        echo "Update Wsl settings to use Droid Sans Mono Font"
        wsl.exe -d %distro_name% -- sh -c "chmod +x %target_dir%/playbooks/files/update_wsl_settings.sh && bash %target_dir%/playbooks/files/update_wsl_settings.sh %distro_name% '%font_name%' %use_acrylic% %opacity% %wsl_settings_file%"
    )
)

echo "Script finished."