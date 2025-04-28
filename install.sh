#!/bin/bash
# Perfect Environment Installer for Unix-like systems (macOS and Linux)
# This script installs the Perfect environment configuration

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
else
  echo "Unsupported operating system: $OSTYPE"
  exit 1
fi

# Source common and OS-specific functions
source "$(dirname "$0")/installers/common.sh"
source "$(dirname "$0")/installers/$OS.sh"

# Create default user-config.yaml if it doesn't exist
if [ ! -f "$(dirname "$0")/user-config.yaml" ]; then
  create_default_config
fi

# Install core components
echo "Installing core components..."
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