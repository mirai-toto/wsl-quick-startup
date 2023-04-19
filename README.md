# WSL Quick Startup
WSL Quick Startup is an Ansible project that installs a set of tools on a Windows Subsystem for Linux (WSL) instance. It is designed to help developers quickly set up a development environment on a Windows machine.

# Features
Installs a WSL instance on a Windows machine and configures the following tools and settings for the instance:
- npm
- bat
- neofetch
- Python 3
- Java 11
- Docker
- k3s or kubeadm
- k9s
- Helm
- zsh, oh my zsh and zsh plugins (powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions)
- Sets proxy values for the WSL instance
- Configures WSL settings in `wsl.conf`
- Configures vim and git settings for development

# Installation
To use WSL Quick Startup, follow these steps:

1. Open a PowerShell console as Administrator and run the following command to enable WSL:
```powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```
2. Clone this repository to your local machine
3. Edit the `vars.yml` file in the `group_vars/all` directory to specify your desired settings, such as the proxy server address and port.
4. Edit the `config.txt` file to customize installation.
5. execute the `main.bat` script located in the root of the repository.

# Usage
Once you've completed the installation steps above, you can use the following commands to manage your WSL instance:

Sure, here is an updated version of the Usage section in table format with columns for name, description, and example:

### WSL Quick Startup - Settings file for the main script

| Name | Description | Example |
|------|-------------|---------|
| `distro_name` | The name of the Linux distribution that will be installed. | UbuntuTest |
| `install_dir` | The directory where the WSL instance will be installed. | %userprofile%\VMs |
| `iso_file` | The path to the Linux distribution tar file. | %userprofile%\ubuntu-jammy-wsl-amd64-wsl.rootfs.tar.gz |
| `install_font` | Boolean value to determin whether to install font or not. | true |

### WSL Quick Startup - Ansible Variables

| Name                   | Description                                                       | Example                                                          |
|------------------------|-------------------------------------------------------------------|------------------------------------------------------------------|
| use_k3s                | Boolean value to determine whether to use k3s or kubeadm.         | `true`                                                           |
| user                   | The username to create or use.                                    | `my-user`                                                        |
| create_user            | Boolean value to determine whether to create the user or not.     | `true`                                                           |
| user_password          | The password for the user.                                        | `password`                                                       |
| helm.version           | The version of Helm to install.                                   | `v3.0.0`                                                         |
| install_zsh            | Boolean value to determine whether to install Zsh or not.         | `true`                                                           |
| proxy_parameters.use_proxy | Boolean value to determine whether to use a proxy or not.     | `false` |
| proxy_parameters.https_proxy | The HTTPS proxy URL to use.                                        | `HTTPS_PROXY_URL`                                                |
| proxy_parameters.http_proxy | The HTTP proxy URL to use.                                          | `HTTP_PROXY_URL`                                                 |
| proxy_parameters.no_proxy | The no proxy URL to use.                                            | `NO_PROXY_URL`                                                   |


To start the WSL instance: `wsl`
To stop the WSL instance: `wsl --shutdown`

# Support
If you have any questions or issues with WSL Quick Startup, please create a new issue in the GitHub repository.

# Contributing
If you'd like to contribute to WSL Quick Startup, please follow these steps:

Fork the repository
Create a new branch for your changes
Make your changes and commit them with a descriptive commit message
Push your changes to your fork
Create a pull request to the original repository

# License
WSL Quick Startup is released under the MIT License.

# Credits
WSL Quick Startup was created by mirai-toto.

# Acknowledgements
Special thanks to the contributors of the open source tools used in this project, including Ansible, Docker, k3s, helm and WSL.



