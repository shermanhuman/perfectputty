# Perfect Environment

A cross-platform environment configuration system for Windows, macOS, and Linux with modular add-ons.

## Overview

Perfect Environment started as a customized shell and configuration for PuTTY on Windows, then grew to include configurations for macOS and Windows 11 PowerShell. It has now been reorganized to provide a unified installation experience across all three major operating systems.

## Features

- **Cross-Platform**: Works on Windows 11, macOS, and Linux
- **Unified Configuration**: Shared color schemes, fonts, and settings across platforms
- **Modular Add-ons**: Optional components like PuTTY, Miniconda, and Node.js
- **Simple Installation**: One-line installation command

## Installation

### Windows

```powershell
# Run in PowerShell as Administrator
iwr -useb https://raw.githubusercontent.com/username/perfectputty/install.ps1 | iex
```

### macOS/Linux

```bash
# Run in Terminal
curl -fsSL https://raw.githubusercontent.com/username/perfectputty/install.sh | bash
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

## Credits

- [Nerd Fonts](https://www.nerdfonts.com/) - SauceCodePro Nerd Font
- [Jellybeans](https://github.com/nanotech/jellybeans.vim) - Original inspiration for the color scheme
