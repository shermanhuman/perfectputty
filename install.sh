#!/bin/bash
# Perfect Environment Installer for Unix-like systems (macOS and Linux)
# This script installs the Perfect environment configuration

# Determine if running remotely or locally
is_remote=false
if [ "$0" = "bash" ]; then
  is_remote=true
fi

# Set repository URL
repo_url="https://raw.githubusercontent.com/shermanhuman/perfectputty/master"

# Set base directory
if [ "$is_remote" = true ]; then
  base_dir="/tmp/perfectputty_install"
  mkdir -p "$base_dir"
else
  base_dir="$(dirname "$0")"
fi

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
else
  echo "Unsupported operating system: $OSTYPE"
  exit 1
fi

# Function to download a file if running remotely
get_remote_file() {
  local relative_path="$1"
  local output_path="$2"
  
  if [ "$is_remote" = true ]; then
    echo "Downloading $repo_url/$relative_path..."
    curl -fsSL "$repo_url/$relative_path" -o "$output_path"
  fi
}

# Create necessary directories
if [ "$is_remote" = true ]; then
  mkdir -p "$base_dir/installers"
  mkdir -p "$base_dir/core/profiles"
  mkdir -p "$base_dir/core/terminal"
  mkdir -p "$base_dir/core/colors"
fi

# Download or source common and OS-specific functions
common_path="$base_dir/installers/common.sh"
os_path="$base_dir/installers/$OS.sh"

if [ "$is_remote" = true ]; then
  get_remote_file "installers/common.sh" "$common_path"
  get_remote_file "installers/$OS.sh" "$os_path"
  chmod +x "$common_path" "$os_path"
fi

# Source the modules
source "$common_path"
source "$os_path"

# Create default user-config.yaml if it doesn't exist
config_path="$base_dir/user-config.yaml"
if [ ! -f "$config_path" ]; then
  cat > "$config_path" << EOF
# Global user configuration
colorScheme: Perfect16
font:
  family: SauceCodePro Nerd Font
  size: 12
terminal:
  scrollback: 10000
EOF
  echo "Created default user configuration at $config_path"
fi

# Download core files if running remotely
if [ "$is_remote" = true ]; then
  get_remote_file "core/profiles/shell_profile.sh" "$base_dir/core/profiles/shell_profile.sh"
  get_remote_file "core/terminal/$OS.terminal" "$base_dir/core/terminal/$OS.terminal"
  get_remote_file "core/colors/perfect16.yaml" "$base_dir/core/colors/perfect16.yaml"
fi

# Install core components
echo "Installing core components..."

# Install shell profile
profile_path="$HOME/.profile"
template_path="$base_dir/core/profiles/shell_profile.sh"

if [ -f "$template_path" ]; then
  cp "$template_path" "$profile_path"
  echo "Shell profile installed to $profile_path"
else
  echo "Shell profile template not found at $template_path"
fi

# Install terminal config
if [ "$OS" = "macos" ]; then
  echo "Installing Terminal.app configuration..."
  
  terminal_path="$base_dir/core/terminal/macos.terminal"
  if [ -f "$terminal_path" ]; then
    # Create Terminal.app profiles directory if it doesn't exist
    mkdir -p "$HOME/Library/Application Support/Terminal"
    
    # Copy terminal configuration
    cp "$terminal_path" "$HOME/Library/Application Support/Terminal/Perfect.terminal"
    
    # Set as default
    defaults write com.apple.Terminal "Default Window Settings" -string "Perfect"
    defaults write com.apple.Terminal "Startup Window Settings" -string "Perfect"
    
    echo "Terminal.app configuration installed!"
  else
    echo "Terminal.app configuration not found at $terminal_path"
  fi
elif [ "$OS" = "linux" ]; then
  echo "Installing terminal configuration for Linux..."
  # Linux terminal configuration would go here
  # This is simplified for brevity
fi

# Install fonts
echo -n "Would you like to install the SauceCodePro Nerd Font? (y/n): "
read -r install_fonts

if [ "$install_fonts" = "y" ]; then
  echo "Downloading SauceCodePro Nerd Font..."
  font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip"
  font_zip="/tmp/SauceCodePro.zip"
  font_dir="/tmp/SauceCodePro"
  
  # Download font
  curl -L "$font_url" -o "$font_zip"
  
  # Extract font
  mkdir -p "$font_dir"
  unzip -q "$font_zip" -d "$font_dir"
  
  # Install font
  if [ "$OS" = "macos" ]; then
    mkdir -p "$HOME/Library/Fonts"
    cp "$font_dir"/*.ttf "$HOME/Library/Fonts/"
  else
    mkdir -p "$HOME/.local/share/fonts"
    cp "$font_dir"/*.ttf "$HOME/.local/share/fonts/"
    fc-cache -f -v
  fi
  
  # Clean up
  rm -f "$font_zip"
  rm -rf "$font_dir"
  
  echo "Fonts installed successfully!"
fi

# Clean up if running remotely
if [ "$is_remote" = true ] && [ -d "$base_dir" ]; then
  rm -rf "$base_dir"
fi

echo "Installation complete!"