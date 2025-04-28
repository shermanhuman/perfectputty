# Perfect Environment - Reorganization Plan

This document outlines a comprehensive plan for reorganizing the "perfectputty" project into a cross-platform environment configuration system with modular add-ons.

## Goals

- Create a unified installation experience across Windows, macOS, and Linux
- Share common configurations (colors, fonts, settings) across platforms
- Modularize add-ons for easy selection and installation
- Maintain a simple, streamlined installation process
- Follow DRY (Don't Repeat Yourself) principles

## Folder Structure

```
perfectputty/
├── core/                      # Shared configurations
│   ├── colors/                # Color schemes
│   │   ├── perfect16.json     # Universal color scheme in JSON format
│   │   └── themes/            # Additional themes
│   ├── fonts/                 # Font files
│   │   ├── dejavu/
│   │   └── inconsolata/
│   ├── settings/              # Common settings
│   │   └── defaults.json      # Default terminal settings
│   └── sounds/                # Sound files
│       └── pop.wav            # Bell sound
│
├── installers/                # OS-specific installer modules
│   ├── windows.ps1            # Windows-specific installation functions
│   ├── macos.sh               # macOS-specific installation functions
│   ├── linux.sh               # Linux-specific installation functions
│   └── common.sh              # Shared installer functions
│
├── addons/                    # Modular add-ons
│   ├── putty/                 # PuTTY configuration (Windows-only)
│   │   ├── config.json        # Configuration metadata
│   │   └── windows.ps1        # Windows installation script
│   ├── miniconda/             # Miniconda configuration
│   │   ├── config.json        # Configuration metadata
│   │   ├── windows.ps1        # Windows installation script
│   │   ├── macos.sh           # macOS installation script
│   │   └── linux.sh           # Linux installation script
│   ├── nodejs/                # Node.js configuration
│   │   ├── config.json
│   │   ├── windows.ps1
│   │   ├── macos.sh
│   │   └── linux.sh
│   └── [other add-ons...]
│
├── docs/                      # Documentation
│   ├── screenshots/           # Screenshots for documentation
│   └── addons.md              # Add-on documentation
│
├── install.sh                 # Universal installer script (bash)
├── install.ps1                # Universal installer script (PowerShell)
└── README.md                  # Project overview
```

## Configuration Format

### Core Color Scheme (core/colors/perfect16.json)

```json
{
  "name": "Perfect16",
  "description": "A 16-color scheme optimized for terminal clarity and comfort",
  "colors": {
    "background": "#0F1011",
    "foreground": "#C3C3C3",
    "black": "#444448",
    "blue": "#66728e",
    "cyan": "#6F99A6",
    "green": "#799D6A",
    "purple": "#AF87AE",
    "red": "#B94D35",
    "white": "#DDDDDD",
    "yellow": "#FFB964",
    "brightBlack": "#554F4F",
    "brightBlue": "#82A3BF",
    "brightCyan": "#91CADB",
    "brightGreen": "#7CB165",
    "brightPurple": "#EABBe9",
    "brightRed": "#D65F45",
    "brightWhite": "#EFEFE0",
    "brightYellow": "#FAD07A"
  }
}
```

### Core Settings (core/settings/defaults.json)

```json
{
  "terminal": {
    "scrollback": 10000,
    "cursorStyle": "block",
    "cursorBlink": true,
    "fontFamily": "DejaVu Sans Mono",
    "fontSize": 12,
    "padding": 4,
    "bellSound": "pop.wav",
    "bellStyle": "sound"
  }
}
```

### Add-on Manifest (addons/[addon-name]/config.json)

```json
{
  "name": "Miniconda",
  "description": "Python distribution with package manager",
  "version": "1.0.0",
  "platforms": ["windows", "macos", "linux"],
  "dependencies": [],
  "category": "Development",
  "default": true,
  "tags": ["python", "conda", "development"]
}
```

## Installer Design

### Universal Installer (install.sh)

The main installer script will:

1. Detect the operating system
2. Source the appropriate OS-specific module from the installers directory
3. Install core components (colors, fonts, settings)
4. Scan the addons directory and read all config.json files
5. Present a simple text-based menu of available add-ons for the current OS
6. Install selected add-ons

```bash
#!/bin/bash

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
else
  echo "Unsupported operating system: $OSTYPE"
  exit 1
fi

# Source OS-specific functions
source "$(dirname "$0")/installers/common.sh"
source "$(dirname "$0")/installers/$OS.sh"

# Install core components
install_core

# Scan and present add-ons
scan_addons
present_addon_menu
install_selected_addons

echo "Installation complete!"
```

### PowerShell Wrapper (install.ps1)

For Windows, a PowerShell wrapper will provide the same functionality:

```powershell
# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Warning "Please run as administrator!"
  exit
}

# Source common and Windows-specific functions
. "$PSScriptRoot\installers\common.ps1"
. "$PSScriptRoot\installers\windows.ps1"

# Install core components
Install-Core

# Scan and present add-ons
$Addons = Scan-Addons
$Selected = Present-AddonMenu -Addons $Addons
Install-SelectedAddons -Selected $Selected

Write-Host "Installation complete!" -ForegroundColor Green
```

### Menu System

The add-on selection menu will be simple and text-based:

```
=== Available Add-ons ===

1. [x] Miniconda - Python distribution with package manager
2. [x] Node.js - JavaScript runtime environment
3. [ ] PuTTY - SSH and telnet client (Windows only)
4. [ ] Bun - JavaScript runtime and toolkit

Enter numbers to toggle selection (e.g., "3 4"), or press Enter to continue:
```

## Migration Plan

### Phase 1: Create New Structure

1. Set up the new folder structure
2. Create placeholder files for the new configuration format

### Phase 2: Extract Shared Configurations

1. Extract color schemes from all platforms into shared JSON format
   - Convert Windows Terminal colors from WindowsTerminalColorScheme-Perfect.JSON
   - Extract colors from macOS Perfect.terminal
   - Extract colors from PuTTY registry settings
   
2. Standardize terminal settings
   - Extract common settings from all platforms
   - Create defaults.json with shared settings

3. Organize fonts and sounds
   - Move font files to core/fonts directory
   - Move pop.wav to core/sounds directory

### Phase 3: Create Add-ons

1. Create PuTTY add-on (Windows-only)
   - Extract PuTTY-specific settings from default-settings.reg
   - Create config.json and windows.ps1 implementation

2. Create Miniconda add-on
   - Extract configuration from PowerShell profile
   - Create implementation scripts for all platforms

3. Create Node.js/fnm add-on
   - Extract configuration from PowerShell profile
   - Create implementation scripts for all platforms

4. Create additional add-ons as needed

### Phase 4: Develop Installer Scripts

1. Create common installer functions
   - Functions for reading JSON configurations
   - Functions for presenting menus
   - Functions for installing add-ons

2. Create OS-specific installer modules
   - Windows: PowerShell functions for registry, fonts, etc.
   - macOS: Bash functions for Terminal profiles, fonts, etc.
   - Linux: Bash functions for terminal configurations

3. Create the unified installer scripts
   - Bash script for macOS/Linux
   - PowerShell script for Windows

### Phase 5: Testing and Documentation

1. Test installation on all platforms
2. Create documentation with screenshots
3. Update README.md with new installation instructions

## Implementation Examples

### Add-on Implementation (addons/miniconda/windows.ps1)

```powershell
function Install-Miniconda {
  param (
    [string]$InstallDir = "$env:USERPROFILE\miniconda3"
  )
  
  # Check if already installed
  if (Test-Path "$InstallDir\Scripts\conda.exe") {
    Write-Host "Miniconda already installed at $InstallDir" -ForegroundColor Yellow
    return
  }
  
  # Download and install Miniconda
  $installerUrl = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
  $installerPath = "$env:TEMP\miniconda_installer.exe"
  
  Write-Host "Downloading Miniconda installer..." -ForegroundColor Cyan
  Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
  
  Write-Host "Installing Miniconda to $InstallDir..." -ForegroundColor Cyan
  Start-Process -FilePath $installerPath -ArgumentList "/S /D=$InstallDir" -Wait
  
  # Add to PowerShell profile
  $profileContent = @"
# Miniconda initialization
`$condaPath = "$InstallDir\Scripts\conda.exe"
if (Test-Path `$condaPath) {
    Write-Host "... " -ForegroundColor Green -NoNewline
    & `$condaPath "shell.powershell" "hook" | Out-Null
    `$pythonVersion = (python --version) -replace "Python ", ""
    Write-Host "Miniconda loaded: Python `$pythonVersion" -ForegroundColor Green
}
"@
  
  Add-Content -Path $PROFILE -Value $profileContent
  
  Write-Host "Miniconda installed successfully!" -ForegroundColor Green
}

# Call the installation function
Install-Miniconda
```

### OS-Specific Module (installers/macos.sh)

```bash
#!/bin/bash

# Install core components for macOS
function install_core() {
  echo "Installing core components for macOS..."
  
  # Install fonts
  mkdir -p ~/Library/Fonts
  cp -r "$(dirname "$0")/../core/fonts/dejavu/"*.ttf ~/Library/Fonts/
  
  # Install terminal profile
  TERM_PROFILE="$(dirname "$0")/../core/settings/Perfect.terminal"
  defaults write com.apple.Terminal "Default Window Settings" -string "Perfect"
  defaults write com.apple.Terminal "Startup Window Settings" -string "Perfect"
  
  # Convert JSON color scheme to Terminal.app format
  generate_terminal_profile
  
  echo "Core components installed!"
}

# Generate Terminal.app profile from JSON color scheme
function generate_terminal_profile() {
  # This would convert the JSON color scheme to a Terminal.app profile
  # For simplicity, we're not showing the full implementation here
  echo "Generating Terminal.app profile from color scheme..."
}

# Install an add-on for macOS
function install_addon() {
  local addon_dir="$1"
  
  if [ -f "$addon_dir/macos.sh" ]; then
    echo "Installing add-on: $(basename "$addon_dir")..."
    bash "$addon_dir/macos.sh"
  fi
}
```

## Next Steps

After approval of this plan, we will:

1. Create the new directory structure
2. Begin migrating existing configurations to the new format
3. Develop the installer scripts
4. Test the installation process on all platforms