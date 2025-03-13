# WSL Quick Startup

WSL Quick Startup is an Ansible-based project designed to install and configure a Windows Subsystem for Linux (WSL) instance, providing a comprehensive setup for development environments.

## Features

- Installs and configures a WSL instance.
- Automates development tool setup via the `dev-quick-startup` submodule.
- Installs `sakai135/wsl-vpnkit` for VPN support.
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

  If already cloned without submodules:

  ```bash
  git submodule update --init --recursive
  ```

- **Edit Configuration Files**: Modify `config.cfg` to customize the installation.

- **Run the Main Script**: Execute the setup script:

  ```powershell
  scripts\MainScript.ps1
  ```

## Configuration

### Main Configuration `config.cfg`

#### Table 1: Core Settings

| Name              | Description                                    | Default     |
| ----------------- | ---------------------------------------------- | ----------- |
| wsl_instance_name | Name of the WSL distribution to be installed.  | `UbuntuWsl` |
| dev_user          | Username to create in WSL.                     | `wsl-user`  |
| dev_password      | Password for the created user.                 | `root`      |
| http_proxy_wsl    | HTTP proxy for WSL.                            | X           |
| https_proxy_wsl   | HTTPS proxy for WSL.                           | X           |
| no_proxy_wsl      | Comma-separated list of hosts bypassing proxy. | X           |
| use_k3s           | Use k3s instead of kubeadm for Kubernetes.     | `true`      |

#### Table 2: Additional Settings

| Name                | Description                                         | Default                                                                                               |
| ------------------- | --------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| wsl_install_dir     | Directory where the WSL instance will be installed. | `%userprofile%\VMs`                                                                                   |
| wsl_iso_file        | Path to the Linux distribution tar file.            | `%userprofile%\Downloads\ubuntu-noble-wsl-amd64-ubuntu.rootfs.tar.gz`                                 |
| wsl_default_iso_url | URL to download ISO if none is provided.            | `https://cloud-images.ubuntu.com/wsl/releases/noble/current/ubuntu-noble-wsl-amd64-wsl.rootfs.tar.gz` |
| customize_terminal  | Install terminal fonts and packages using winget.   | `false`                                                                                               |
| vpn_toolkit_version | Version of WSL VPN Toolkit to install.              | `v0.4.1`                                                                                              |

## Usage

Once you've completed the installation steps above, you can use the following commands to manage your WSL instance:

- **Start the WSL instance**:

  ```powershell
  wsl -d $wsl_instance_name -u $dev_user
  ```

  Replace `$wsl_instance_name` with your WSL distribution name and `$dev_user` with your WSL username.

- **Stop the WSL instance**:

  ```powershell
  wsl --shutdown
  ```

## License

Dev Quick Startup is released under the [MIT License](LICENSE).

## Support

If you have any questions or issues with WSL Quick Startup, please create a new issue in the [GitHub repository](https://github.com/mirai-toto/wsl-quick-startup/issues).

## Credits

WSL Quick Startup was created by [mirai-toto](https://github.com/mirai-toto).

## Acknowledgements

Special thanks to the contributors of the open-source tools used in this project, including Ansible, Docker, k3s, kubeadm, k9s, Helm, zsh, WSL, and wsl-vpnkit.
