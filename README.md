# WSL Quick Startup

WSL Quick Startup is a PowerShell-based project that installs and configures a WSL instance using cloud-init.

## ✨ Features

* Creates and configures a WSL instance from a rootfs tarball
* Uses cloud-init for user setup and software installation
* Installs Docker, k3s, Helm, and VPN support with `wsl-vpnkit`
* Supports proxy configuration

## ⚙️ Requirements

* **PowerShell 7+**

  ```powershell
  winget install --id Microsoft.PowerShell --source winget
  ```

* **WSL enabled** (run as Administrator):

  ```powershell
  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
  ```

## 🚀 Installation

```bash
git clone https://github.com/mirai-toto/wsl-quick-startup.git
cd wsl-quick-startup
pwsh MainScript.ps1
```

## 🔧 Configuration

Edit the `config.json` file to customize your setup.

### 🏷️ WSL Instance Settings

| Key                | Description                             | Default                                                                                               |
| ------------------ | --------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `hostname`         | Name of the WSL instance                | `Ubuntu`                                                                                              |
| `wslInstallDir`    | Installation directory                  | `%userprofile%/VMs`                                                                                   |
| `wslIsoFile`       | Path to the rootfs tarball              | `%userprofile%/Downloads/ubuntu-noble-wsl-amd64-ubuntu.rootfs.tar.gz`                                 |
| `wslDefaultIsoUrl` | Fallback URL if `wslIsoFile` is missing | `https://cloud-images.ubuntu.com/wsl/releases/noble/current/ubuntu-noble-wsl-amd64-wsl.rootfs.tar.gz` |

### 👤 User Configuration

| Key        | Description           | Default   |
| ---------- | --------------------- | --------- |
| `username` | User to create in WSL | `wsluser` |
| `password` | Password for the user | `root`    |

### 🌐 Proxy Settings (Optional)

| Key             | Description            | Default |
| --------------- | ---------------------- | ------- |
| `httpProxyWsl`  | HTTP proxy inside WSL  | `""`    |
| `httpsProxyWsl` | HTTPS proxy inside WSL | `""`    |
| `noProxyWsl`    | No-proxy host list     | `""`    |

### 🛠️ Advanced Settings

| Key                     | Description                      | Default                                                                             |
| ----------------------- | -------------------------------- | ----------------------------------------------------------------------------------- |
| `cloudInitTemplateFile` | Path to cloud-init template file | `cloud-init.template.yaml`                                                          |
| `vpnToolkitUrl`         | URL to download `wsl-vpnkit`     | `https://github.com/sakai135/wsl-vpnkit/releases/download/v0.4.1/wsl-vpnkit.tar.gz` |

## 🧪 Usage

* **Start your instance**:

  ```powershell
  wsl -d <hostname>
  ```

* **Shutdown all instances**:

  ```powershell
  wsl --shutdown
  ```

## 📄 License

MIT — see [LICENSE](LICENSE)

## 🛟 Support

Open an issue at [GitHub Issues](https://github.com/mirai-toto/wsl-quick-startup/issues)

## 👤 Credits

Made by [mirai-toto](https://github.com/mirai-toto)

## 🙏 Acknowledgements

Thanks to the maintainers of:
WSL, cloud-init, Docker, k3s, Helm, wsl-vpnkit