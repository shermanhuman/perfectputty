# Perfect Environment

A cross-platform environment configuration system for Windows, macOS, and Linux with modular add-ons.

## Overview

Perfect Environment started as a customized shell and configuration for PuTTY on Windows, then grew to include configurations for macOS and Windows 11 PowerShell. It has now been reorganized to provide a unified installation experience across all three major operating systems.

## Features

- **Cross-Platform**: Works on Windows 11, macOS, and Linux
- **Unified Configuration**: Shared color schemes, fonts, and settings across platforms
- **Modular Add-ons**: Optional components like PuTTY, uv, and Node.js
- **Simple Installation**: One-line installation command
- **Safe Configuration**: Automatic backups of existing settings before modifications with timestamped files stored in a dedicated directory
- **Robust Installation**: Reliable download and installation process with pre-download, progress tracking, retry logic, and automatic cleanup
- **Error Recovery**: If an installation step fails, you'll be offered the option to restore from backup

## Installation

### Windows

Run in PowerShell as Administrator:

```powershell
iwr -useb https://raw.githubusercontent.com/shermanhuman/perfectputty/master/dist/install.ps1 | iex
```

For local installation:
```powershell
cd path\to\perfectputty
.\dist\install.ps1
```

### Linux

Run in Terminal:
```bash
curl -fsSL https://raw.githubusercontent.com/shermanhuman/perfectputty/master/dist/install-linux.sh | bash
```

For local installation:
```bash
cd path/to/perfectputty
bash ./dist/install-linux.sh
```

### macOS

Run in Terminal:
```bash
curl -fsSL https://raw.githubusercontent.com/shermanhuman/perfectputty/master/dist/install-mac.sh | bash
```

For local installation:
```bash
cd path/to/perfectputty
bash ./dist/install-mac.sh
```

## What Gets Installed

### Core Components

- **Terminal Configuration**: Colors, fonts, and settings for your terminal
  - Windows: Windows Terminal color scheme
  - macOS: Terminal.app profile
  - Linux: Configuration for various terminal emulators
- **Starship Prompt**: Cross-shell prompt with customizable themes
  - Integrates with add-ons for language-specific information
  - Falls back to custom shell profiles if installation fails
- **Shell Profile**: Custom shell configuration
  - Windows: PowerShell profile with git integration
  - macOS/Linux: Bash/Zsh profile with similar features

### Optional Add-ons

- **PuTTY** (Windows only): SSH and telnet client with custom configuration
  - Uses color scheme from user-config.yaml
  - Configurable font and scrollback settings
- **Python**: Python environment with uv package manager
  - Starship integration for showing Python version and virtual environment
- **Node.js**: JavaScript runtime with fnm version manager
  - Starship integration for showing Node.js version
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
│   ├── color-schemes/         # Color schemes
│   ├── profiles/              # Shell profiles (fallback if Starship fails)
│   ├── shell-themes/          # Starship theme templates
│   ├── terminal/              # Terminal configurations
│   └── sounds/                # Sound files
├── addons/                    # Modular add-ons
│   ├── nodejs/                # Node.js configuration
│   │   ├── config.yaml        # Addon metadata
│   │   ├── install-scripts/   # OS-specific installation scripts
│   │   └── shell/             # Starship configuration
│   ├── putty/                 # PuTTY configuration (Windows-only)
│   │   ├── config.yaml        # Addon metadata
│   │   ├── install-scripts/   # Installation scripts
│   │   └── templates/         # Template files for configuration
│   └── python/                # Python configuration
│       ├── config.yaml        # Addon metadata
│       ├── install-scripts/   # OS-specific installation scripts
│       └── shell/             # Starship configuration
├── build/                     # Build scripts
│   ├── index.js               # Main build script
│   ├── starship-theme-builder.js # Starship theme builder
│   └── putty-template-builder.js # PuTTY template builder
├── install/                   # Installation script templates
│   ├── install.ps1.tmpl       # Windows PowerShell template
│   ├── install-linux.sh.tmpl  # Linux shell template
│   └── install-mac.sh.tmpl    # macOS shell template
├── dist/                      # Build output (generated files)
│   ├── shell-themes/          # Built shell themes
│   ├── addons/                # Built addon configurations
│   ├── install.ps1            # Generated Windows installer
│   ├── install-linux.sh       # Generated Linux installer
│   └── install-mac.sh         # Generated macOS installer
├── tests/                     # Tests
│   ├── common/                # Common test files
│   │   ├── ascii/             # ASCII art for tests
│   │   ├── colortest.ps1      # PowerShell color test
│   │   ├── colortest.sh       # Bash color test
│   │   └── unicode-test.sh    # Unicode test
│   ├── mac_os/                # macOS specific tests
│   ├── run-tests.ps1          # Windows test runner
│   └── run-tests.sh           # Unix test runner
├── user-config.yaml           # User configuration file
├── package.json               # Package info and version
└── LICENSE                    # MIT License
```

## Add-ons

Each add-on is a self-contained module with:

- `config.yaml`: Metadata about the add-on (name, description, supported platforms)
- `install-scripts/`: Directory containing OS-specific installation scripts
  - `windows.ps1`: Windows PowerShell installation script
  - `linux.sh`: Linux installation script
  - `macos.sh`: macOS installation script
- `shell/`: Directory containing Starship configuration (if applicable)
  - `starship.module.toml`: Module entry for the Starship format string
  - `starship.config.toml`: Module configuration for Starship
- `templates/`: Directory containing templates for configuration files (if applicable)

You can select which add-ons to install during the installation process.

## Build Process

The project uses a build system to generate installation scripts and configuration files:

1. Run the build script to generate the installation files:
   ```bash
   npm run build
   ```

2. The build process:
   - Loads the color scheme from `user-config.yaml`
   - Builds the Starship theme with the color palette
   - Processes templates for all addons (like PuTTY settings)
   - Generates installation scripts with embedded file manifests and addon registry
   - Bumps the version number in `package.json`

3. The generated files are placed in the `dist` directory:
   - `dist/shell-themes/perfect.toml`: Starship theme
   - `dist/addons/putty/putty-settings.reg`: PuTTY settings
   - `dist/install.ps1`: Windows installation script
   - `dist/install-linux.sh`: Linux installation script
   - `dist/install-mac.sh`: macOS installation script

## VS Code configuration

You'll need to set your font in VS Code to see the nerd font icons there.  To do that you'll need the font family name.  For Saucecode Pro Mono it's `SauceCodePro NFM`.  If you are using another font you can find the name by opening the font in the Windows Font Viewer under the label 'Font Name'.

## Testing

After installation, you can run tests to verify your setup:

```bash
# On macOS/Linux
bash tests/run-tests.sh

# On Windows
powershell tests/run-tests.ps1
```

## Troubleshooting

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
