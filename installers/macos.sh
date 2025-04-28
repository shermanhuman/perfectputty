#!/bin/bash
# macOS-specific installation functions

function install_shell_profile() {
  local profile_path="$HOME/.profile"
  local template_path="$(dirname "$0")/../core/profiles/shell_profile.sh"
  
  # Read profile template
  if [ -f "$template_path" ]; then
    cp "$template_path" "$profile_path"
    echo "Shell profile installed to $profile_path"
  else
    echo "Shell profile template not found at $template_path"
  fi
}

function install_terminal_config() {
  echo "Installing Terminal.app configuration..."
  
  local terminal_path="$(dirname "$0")/../core/terminal/macos.terminal"
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
}

function install_fonts() {
  echo -n "Would you like to install the SauceCodePro Nerd Font? (y/n): "
  read -r install_fonts
  
  if [ "$install_fonts" != "y" ]; then
    return
  fi
  
  echo "Downloading SauceCodePro Nerd Font..."
  local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip"
  local font_zip="/tmp/SauceCodePro.zip"
  local font_dir="/tmp/SauceCodePro"
  
  # Download font
  curl -L "$font_url" -o "$font_zip"
  
  # Extract font
  mkdir -p "$font_dir"
  unzip -q "$font_zip" -d "$font_dir"
  
  # Install font
  mkdir -p "$HOME/Library/Fonts"
  cp "$font_dir"/*.ttf "$HOME/Library/Fonts/"
  
  # Clean up
  rm -f "$font_zip"
  rm -rf "$font_dir"
  
  echo "Fonts installed successfully!"
}