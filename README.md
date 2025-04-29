# Perfect Environment

A cross-platform environment configuration system for Windows, macOS, and Linux with modular add-ons.

## Overview

Perfect Environment started as a customized shell and configuration for PuTTY on Windows, then grew to include configurations for macOS and Windows 11 PowerShell. It has now been reorganized to provide a unified installation experience across all three major operating systems.

## Features

- **Cross-Platform**: Works on Windows 11, macOS, and Linux
- **Unified Configuration**: Shared color schemes, fonts, and settings across platforms
- **Modular Add-ons**: Optional components like PuTTY, Miniconda, and Node.js
- **Simple Installation**: One-line installation command
- **Safe Configuration**: Automatic backups of existing settings before modifications
- **Robust Installation**: Reliable download and installation process

## Safety Features

Perfect Environment prioritizes the safety of your existing configuration:

- **Automatic Backups**: Before modifying any configuration file, the installer creates a backup
- **Timestamped Files**: All backups include timestamps in the filename for easy identification
- **Central Storage**: Backups are stored in a dedicated `PerfectPutty_Backups` directory in your home folder
- **Error Recovery**: If an installation step fails, you'll be offered the option to restore from backup
- **Platform-Specific Methods**: Uses appropriate backup methods for each platform:
  - Windows: Registry exports, file copies
  - macOS: plist exports, file copies
  - Linux: dconf dumps, file copies

This ensures that your existing terminal settings, shell profiles, and other configurations can be easily restored if needed.

## Installation Safety Features

Perfect Environment uses a robust installation process designed for reliability:

- **Pre-Download**: All required files are downloaded before installation begins
- **Progress Tracking**: Clear progress indicators show download status (current file / total files)
- **File Information**: Shows file sizes during download
- **Retry Logic**: Failed downloads are automatically retried with exponential backoff
- **Error Handling**: Comprehensive error detection and reporting
- **Temporary Storage**: Files are downloaded to a unique temporary directory
- **Automatic Cleanup**: Temporary files are automatically removed after installation

## Installation

### Windows

Run in PowerShell as Administrator:

```powershell
iwr -useb https://raw.githubusercontent.com/shermanhuman/perfectputty/master/install.ps1 | iex
```

For local installation:
```powershell
cd path\to\perfectputty
.\install.ps1
```

### macOS/Linux


Run in Terminal:
```bash
curl -fsSL https://raw.githubusercontent.com/shermanhuman/perfectputty/master/install.sh | bash
```

For local installation:
```bash
cd path/to/perfectputty
bash ./install.sh
```

## What Gets Installed

### Core Components

- **Terminal Configuration**: Colors, fonts, and settings for your terminal
  - Windows: Windows Terminal color scheme
  - macOS: Terminal.app profile
  - Linux: Configuration for various terminal emulators
- **Shell Profile**: Custom shell configuration
  - Windows: PowerShell profile with git integration
  - macOS/Linux: Bash/Zsh profile with similar features

### Optional Add-ons

- **PuTTY** (Windows only): SSH and telnet client with custom configuration
- **Miniconda**: Python distribution with package manager
- **Node.js**: JavaScript runtime with fnm version manager
- More add-ons can be easily created and added

## Customization

You can customize your installation by editing the `user-config.yaml` file in the root directory:

```yaml
# Global user configuration
colorScheme: Perfect16
font:
  family: SauceCodePro Nerd Font
  size: 12
terminal:
  scrollback: 10000
```

## Project Structure

```
perfectputty/
├── core/                      # Core components
│   ├── colors/                # Color schemes
│   ├── fonts/                 # Font files
│   ├── profiles/              # Shell profiles
│   ├── terminal/              # Terminal configurations
│   └── sounds/                # Sound files
├── installers/                # OS-specific installer modules
├── addons/                    # Modular add-ons
│   ├── putty/                 # PuTTY configuration (Windows-only)
│   ├── miniconda/             # Miniconda configuration
│   └── nodejs/                # Node.js configuration
├── tests/                     # Tests
├── install.sh                 # Unix installer script
├── install.ps1                # Windows installer script
└── user-config.yaml           # User configuration file
```

## Add-ons

Each add-on is a self-contained module with:

- `config.yaml`: Metadata about the add-on
- OS-specific installation scripts

You can select which add-ons to install during the installation process.

## Testing

After installation, you can run tests to verify your setup:

```bash
# On macOS/Linux
bash tests/run-tests.sh

# On Windows
powershell tests/run-tests.ps1
```

## Troubleshooting

### Windows Terminal Settings

If you encounter issues with Windows Terminal settings after installation, a repair script is included:

```powershell
# Run in PowerShell
.\fix-terminal-settings.ps1
```

This script:
- Creates a backup of your current Windows Terminal settings
- Fixes common issues with the settings.json file format
- Restores from backup if the repair fails

### Restoring from Backups

All backups are stored in the `PerfectPutty_Backups` directory in your home folder. Each backup includes a timestamp in the filename.

To manually restore a backup:

**Windows PowerShell Profile:**
```powershell
Copy-Item "~/PerfectPutty_Backups/PowerShell_Profile_Backup_YYYYMMDD-HHMMSS.ps1" $PROFILE
```

**Windows Terminal Settings:**
```powershell
Copy-Item "~/PerfectPutty_Backups/Terminal_Settings_Backup_YYYYMMDD-HHMMSS.json" "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
```

**PuTTY Registry Settings:**
```powershell
regedit.exe /s "~/PerfectPutty_Backups/PuTTY_Registry_Backup_YYYYMMDD-HHMMSS.reg"
```

**Unix Shell Profile:**
```bash
cp ~/PerfectPutty_Backups/Shell_Profile_Backup_YYYYMMDD-HHMMSS ~/.profile
```

**Terminal.app Settings (macOS):**
```bash
defaults import com.apple.Terminal ~/PerfectPutty_Backups/Terminal_Settings_Backup_YYYYMMDD-HHMMSS.plist
```

## Credits

- [Nerd Fonts](https://www.nerdfonts.com/) - SauceCodePro Nerd Font
- [Jellybeans](https://github.com/nanotech/jellybeans.vim) - Original inspiration for the color scheme
