# WSL Quick Startup

WSL Quick Startup is an Ansible-based project designed to install and configure a Windows Subsystem for Linux (WSL) instance, providing a comprehensive setup for development environments.

## Features

- Installs and configures a WSL instance.
- Automates development tool setup via the `dev-quick-startup` submodule.
- Handles proxy and environment configurations.
- Customizes the terminal with fonts and packages using `winget`.

## Installation

- **Enable WSL**: Open a PowerShell console as Administrator and run:

   ```powershell
   Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
   ```

- **Clone the Repository**: Clone this repository with the submodule to your local machine.

  ```bash
  git clone --recurse-submodules https://github.com/mirai-toto/wsl-quick-startup.git
  cd wsl-quick-startup
  ```

- **Edit Configuration Files**: Modify `config.cfg` and `custom-config.cfg` to customize the installation

- **Run the Main Script**: Execute the setup script:
  
  ```powershell
  scripts\MainScript.ps1
  ```

## Configuration
### Main Configuration `config.cfg`

#### Table 1: Core Settings

| Name            | Description                                    | Example                          |
|-----------------|------------------------------------------------|----------------------------------|
| distro_name     | Name of the WSL distribution to be installed.  | NewUbuntuWsl                     |
| dev_user        | Username to create in WSL.                     | wsl-user                         |
| dev_password    | Password for the created user.                 | root                             |
| http_proxy_wsl  | HTTP proxy for WSL.                            | <http://proxy.example.com:8080>  |
| https_proxy_wsl | HTTPS proxy for WSL.                           | <https://proxy.example.com:8080> |
| no_proxy_wsl    | Comma-separated list of hosts bypassing proxy. | localhost,127.0.0.1              |
| use_k3s         | Use k3s instead of kubeadm for Kubernetes.     | true                             |

#### Table 2: Additional Settings

| Name                | Description                                                      | Example                                                  |
|---------------------|-----------------------------------------------------|--------------------------------------------------|
| install_dir         | Directory where the WSL instance will be installed. | %userprofile%\VMs                                |
| iso_file            | Path to the Linux distribution tar file.            | %userprofile%\Downloads\ubuntu-noble-wsl-amd64-ubuntu.rootfs.tar.gz |
| default_iso_url     | URL to download ISO if none is provided.            | <https://cloud-images.ubuntu.com/wsl/noble/...>  |
| target_dir          | Directory for wsl-quick-startup within WSL.         | /root/wsl-quick-startup                          |
| customize_terminal  | Install terminal fonts and packages using winget.   | false                                            |

### Custom Configuration `custom-config.cfg`

| Name                 | Description                                                     | Example                                                  |
|----------------------|-----------------------------------------------------------------|----------------------------------------------------------|
| update_windows_terminal_settings  | Update settings of the Windows Terminal.                        | true                                                     |
| windows_terminal_settings    | Path to the Windows Terminal settings file.                  | /mnt/c/Users/%username%/AppData/.../settings.json        |
| font_name            | Name of the font to install for the terminal.                   | DroidSansM Nerd Font Mono                                |
| font_url             | URL to download the font.                                       | <https://github.com/.../DroidSansMono.zip>               |
| font_file            | Font file name for installation.                                | DroidSansMNerdFontMono-Regular.otf                       |
| use_acrylic          | Enable acrylic effect for the WSL instance.                     | true                                                     |
| opacity              | Set opacity level for WSL instance (0-100).                     | 90                                                       |

## Usage

Once you've completed the installation steps above, you can use the following commands to manage your WSL instance:

- **Start the WSL instance**:

  ```powershell
  wsl -d $distro_name -u $dev_user
  ```

Replace `$distro_name` with your WSL distribution name and `$dev_user` with your WSL username.

- **Stop the WSL instance**:

  ```powershell
  wsl --shutdown
  ```

## Support

If you have any questions or issues with WSL Quick Startup, please create a new issue in the [GitHub repository](https://github.com/mirai-toto/wsl-quick-startup/issues).

## License

WSL Quick Startup is released under the [MIT License](LICENSE).

## Credits

WSL Quick Startup was created by [mirai-toto](https://github.com/mirai-toto).

## Acknowledgements

Special thanks to the contributors of the open-source tools used in this project, including Ansible, Docker, k3s, kubeadm, k9s, Helm, zsh and WSL.
