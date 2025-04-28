# Perfect Environment - Revised Reorganization Plan

This document outlines a comprehensive plan for reorganizing the "perfectputty" project into a cross-platform environment configuration system with modular add-ons.

## Goals

- Create a unified installation experience across Windows, macOS, and Linux
- Share common configurations (colors, fonts, settings) across platforms
- Modularize add-ons for easy selection and installation
- Maintain a simple, streamlined installation process
- Follow DRY (Don't Repeat Yourself) principles
- Ensure feature parity across all supported platforms

## Folder Structure

```
perfectputty/
├── core/                      # Core components
│   ├── colors/                # Color schemes
│   │   ├── perfect16.yaml     # Universal color scheme in YAML format
│   │   └── themes/            # Additional themes
│   ├── fonts/                 # Font files
│   │   ├── SauceCodePro/      # Sauce Code Pro Nerd Font
│   │   │   └── LICENSE        # License information
│   │   └── Inconsolata/       # Inconsolata Nerd Font (alternative)
│   │       └── LICENSE        # License information
│   ├── profiles/              # Shell profiles
│   │   ├── powershell.ps1     # PowerShell profile template
│   │   └── shell_profile.sh   # Unix shell profile template (bash/zsh)
│   ├── terminal/              # Terminal configurations
│   │   ├── windows.json       # Windows Terminal configuration
│   │   ├── macos.terminal     # macOS Terminal configuration
│   │   └── linux.conf         # Linux terminal configuration
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
│   │   ├── config.yaml        # Configuration metadata
│   │   └── windows.ps1        # Windows installation script
│   ├── miniconda/             # Miniconda configuration
│   │   ├── config.yaml        # Configuration metadata
│   │   ├── windows.ps1        # Windows installation script
│   │   ├── macos.sh           # macOS installation script
│   │   └── linux.sh           # Linux installation script
│   ├── nodejs/                # Node.js configuration
│   │   ├── config.yaml
│   │   ├── windows.ps1
│   │   ├── macos.sh
│   │   └── linux.sh
│   └── [other add-ons...]
│
├── tests/                     # Tests
│   ├── common/                # Common test files
│   │   ├── colortest.sh       # Color test implementation
│   │   ├── unicode-test.sh    # Unicode test implementation
│   │   └── ascii/             # ASCII art files
│   ├── run-tests.sh           # Test runner for Unix systems
│   └── run-tests.ps1          # Test runner for Windows
│
├── install.sh                 # Universal installer script (bash)
├── install.ps1                # Universal installer script (PowerShell)
├── user-config.yaml           # User configuration file
└── README.md                  # Project overview
```

## User Configuration

The `user-config.yaml` file will contain user-editable global settings:

```yaml
# Global user configuration
colorScheme: Perfect16
font:
  family: SauceCodePro Nerd Font
  size: 12
terminal:
  scrollback: 10000
```

## Add-on Configuration

Each add-on will have a simple `config.yaml` file with metadata:

```yaml
name: Miniconda
description: Python distribution with package manager
platforms:
  - windows
  - macos
  - linux
```

## Installation Process

### Core Components

1. **Shell Profiles**
   - Windows: Install PowerShell profile (Microsoft.PowerShell_profile.ps1)
   - macOS/Linux: Install shell profile (.profile)

2. **Terminal Configurations**
   - Windows: Install Windows Terminal color scheme and settings
   - macOS: Install Terminal.app profile (Perfect.terminal)
   - Linux: Install appropriate terminal configuration

3. **Fonts**
   - Ask user if they want to install fonts
   - Install Sauce Code Pro Nerd Font or Inconsolata Nerd Font

### Add-ons

Each add-on will be presented to the user with a simple text-based menu:

```
=== Available Add-ons ===

1. [x] Miniconda - Python distribution with package manager
2. [x] Node.js - JavaScript runtime environment
3. [ ] PuTTY - SSH and telnet client (Windows only)
4. [ ] Bun - JavaScript runtime and toolkit

Enter numbers to toggle selection (e.g., "3 4"), or press Enter to continue:
```

### Tests

After installation, offer to run tests one at a time:

```
Installation complete!

Would you like to run tests to verify your installation? (y/n): y

Available tests:
1. Color test - Shows all terminal colors
2. Unicode test - Tests Unicode character support
3. ASCII art - Displays ASCII art

Enter test number to run (or 'q' to quit):
```

## Unified Installer

The main installer script will:

1. Detect the operating system
2. Source the appropriate OS-specific module
3. Read or create the user-config.yaml file
4. Install core components (shell profiles, terminal configs, fonts)
5. Present add-on selection menu
6. Install selected add-ons
7. Offer to run tests

### Bash Installer (install.sh)

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

# Create default user-config.yaml if it doesn't exist
if [ ! -f "$(dirname "$0")/user-config.yaml" ]; then
  create_default_config
fi

# Install core components
install_shell_profile
install_terminal_config
install_fonts

# Scan and present add-ons
scan_addons
present_addon_menu
install_selected_addons

# Offer to run tests
offer_tests

echo "Installation complete!"
```

### PowerShell Installer (install.ps1)

```powershell
# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Warning "Please run as administrator!"
  exit
}

# Source common and Windows-specific functions
. "$PSScriptRoot\installers\common.ps1"
. "$PSScriptRoot\installers\windows.ps1"

# Create default user-config.yaml if it doesn't exist
if (-not (Test-Path "$PSScriptRoot\user-config.yaml")) {
  Create-DefaultConfig
}

# Install core components
Install-ShellProfile
Install-TerminalConfig
Install-Fonts

# Scan and present add-ons
$Addons = Scan-Addons
$Selected = Present-AddonMenu -Addons $Addons
Install-SelectedAddons -Selected $Selected

# Offer to run tests
Offer-Tests

Write-Host "Installation complete!" -ForegroundColor Green
```

## OS-Specific Implementation

### Windows

1. **Shell Profile**
   - Install Microsoft.PowerShell_profile.ps1 to the user's PowerShell profile directory
   - Based on the current win11/Microsoft.PowerShell_profile.ps1

2. **Terminal Configuration**
   - Install Windows Terminal color scheme using Install-wt-color-scheme.ps1
   - Based on the current win11/WindowsTerminalColorScheme-Perfect.JSON

3. **Add-ons**
   - PuTTY: Install registry settings from default-settings.reg
   - Miniconda: Install and configure in PowerShell profile
   - Node.js/fnm: Install and configure in PowerShell profile

### macOS

1. **Shell Profile**
   - Install .profile to the user's home directory
   - Update to match features of the Windows PowerShell profile

2. **Terminal Configuration**
   - Install Perfect.terminal to the user's Terminal.app settings
   - Configure font settings

3. **Add-ons**
   - Miniconda: Install and configure in .profile
   - Node.js/fnm: Install and configure in .profile

### Linux

1. **Shell Profile**
   - Install .profile to the user's home directory
   - Update to match features of the Windows PowerShell profile

2. **Terminal Configuration**
   - Create appropriate terminal configuration files based on detected terminal

3. **Add-ons**
   - Miniconda: Install and configure in .profile
   - Node.js/fnm: Install and configure in .profile

## Test System

The test system will use a common implementation with OS-specific wrappers:

1. **Common Test Files**
   - `colortest.sh`: Core implementation of the color test
   - `unicode-test.sh`: Core implementation of the Unicode test
   - `ascii/`: ASCII art files

2. **OS-Specific Wrappers**
   - `run-tests.sh`: Unix wrapper for running tests
   - `run-tests.ps1`: Windows wrapper for running tests

This approach allows us to maintain a single implementation of each test while providing OS-specific execution environments.

## Migration Plan

### Phase 1: Create New Structure

1. Set up the new folder structure
2. Download and add the Nerd Fonts to the repository
3. Create the user-config.yaml file with default settings

### Phase 2: Migrate Core Components

1. **Shell Profiles**
   - Copy Microsoft.PowerShell_profile.ps1 to core/profiles/powershell.ps1
   - Update .profile to match features of PowerShell profile
   - Create core/profiles/shell_profile.sh based on updated .profile

2. **Terminal Configurations**
   - Copy WindowsTerminalColorScheme-Perfect.JSON to core/terminal/windows.json
   - Copy Perfect.terminal to core/terminal/macos.terminal
   - Create Linux terminal configuration template

3. **Fonts and Sounds**
   - Add Nerd Fonts to core/fonts directory
   - Move pop.wav to core/sounds directory

### Phase 3: Create Add-ons

1. Create PuTTY add-on (Windows-only)
   - Extract PuTTY-specific settings from default-settings.reg
   - Create config.yaml and windows.ps1 implementation

2. Create Miniconda add-on
   - Extract configuration from PowerShell profile
   - Create implementation scripts for all platforms

3. Create Node.js/fnm add-on
   - Extract configuration from PowerShell profile
   - Create implementation scripts for all platforms

### Phase 4: Develop Installer Scripts

1. Create common installer functions
   - Functions for reading YAML configurations
   - Functions for presenting menus
   - Functions for installing add-ons

2. Create OS-specific installer modules
   - Windows: PowerShell functions for registry, fonts, etc.
   - macOS: Bash functions for Terminal profiles, fonts, etc.
   - Linux: Bash functions for terminal configurations

3. Create the unified installer scripts
   - Bash script for macOS/Linux
   - PowerShell script for Windows

### Phase 5: Migrate Tests

1. Move existing tests to the tests/common directory
2. Create OS-specific test wrappers
3. Integrate test execution into the installer

## Implementation Examples

### Shell Profile Installation (installers/windows.ps1)

```powershell
function Install-ShellProfile {
  $profileDir = Split-Path $PROFILE
  $profilePath = $PROFILE
  
  # Create profile directory if it doesn't exist
  if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
  }
  
  # Read user configuration
  $config = Get-Content "$PSScriptRoot\..\user-config.yaml" | ConvertFrom-Yaml
  
  # Read profile template
  $profileTemplate = Get-Content "$PSScriptRoot\..\core\profiles\powershell.ps1" -Raw
  
  # Replace variables in template
  $profileTemplate = $profileTemplate -replace '\$\{fontFamily\}', $config.font.family
  $profileTemplate = $profileTemplate -replace '\$\{fontSize\}', $config.font.size
  
  # Write to profile
  Set-Content -Path $profilePath -Value $profileTemplate
  
  Write-Host "PowerShell profile installed to $profilePath" -ForegroundColor Green
}
```

### Terminal Configuration (installers/macos.sh)

```bash
function install_terminal_config() {
  echo "Installing Terminal.app configuration..."
  
  # Copy terminal configuration
  cp "$(dirname "$0")/core/terminal/macos.terminal" "$HOME/Library/Application Support/Terminal/Perfect.terminal"
  
  # Set as default
  defaults write com.apple.Terminal "Default Window Settings" -string "Perfect"
  defaults write com.apple.Terminal "Startup Window Settings" -string "Perfect"
  
  echo "Terminal.app configuration installed!"
}
```

### Test Runner (tests/run-tests.sh)

```bash
#!/bin/bash

# Test runner for Unix systems

function run_color_test() {
  bash "$(dirname "$0")/common/colortest.sh"
}

function run_unicode_test() {
  bash "$(dirname "$0")/common/unicode-test.sh"
}

function run_ascii_art() {
  for file in "$(dirname "$0")/common/ascii/"*.ascii; do
    cat "$file"
    echo
  done
}

# Main menu
echo "Available tests:"
echo "1. Color test - Shows all terminal colors"
echo "2. Unicode test - Tests Unicode character support"
echo "3. ASCII art - Displays ASCII art"
echo
echo "Enter test number to run (or 'q' to quit): "
read -r test_choice

case "$test_choice" in
  1)
    run_color_test
    ;;
  2)
    run_unicode_test
    ;;
  3)
    run_ascii_art
    ;;
  q|Q)
    exit 0
    ;;
  *)
    echo "Invalid choice."
    exit 1
    ;;
esac
```

## Next Steps

After approval of this revised plan, we will:

1. Create the new directory structure
2. Download and add the Nerd Fonts to the repository
3. Begin migrating existing configurations to the new format
4. Develop the installer scripts
5. Test the installation process on all platforms