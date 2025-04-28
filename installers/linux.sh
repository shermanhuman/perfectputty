#!/bin/bash
# Linux-specific installation functions

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
  echo "Installing terminal configuration..."
  
  # Detect terminal
  if [ -d "$HOME/.config/gnome-terminal" ]; then
    install_gnome_terminal_config
  elif [ -d "$HOME/.config/konsole" ]; then
    install_konsole_config
  elif [ -d "$HOME/.config/xfce4/terminal" ]; then
    install_xfce_terminal_config
  else
    echo "Unsupported terminal. Configuration not installed."
    echo "Supported terminals: GNOME Terminal, Konsole, XFCE Terminal"
  fi
}

function install_gnome_terminal_config() {
  echo "Installing GNOME Terminal configuration..."
  
  local config_path="$(dirname "$0")/../core/terminal/linux.conf"
  if [ -f "$config_path" ]; then
    # Create a new profile
    local profile_id=$(uuidgen)
    local dconf_path="/org/gnome/terminal/legacy/profiles:/:$profile_id"
    
    # Load colors from config
    local background=$(grep "^background=" "$config_path" | cut -d "=" -f2)
    local foreground=$(grep "^foreground=" "$config_path" | cut -d "=" -f2)
    
    # Set profile settings
    dconf write "$dconf_path/visible-name" "'Perfect'"
    dconf write "$dconf_path/background-color" "'$background'"
    dconf write "$dconf_path/foreground-color" "'$foreground'"
    dconf write "$dconf_path/use-theme-colors" "false"
    
    # Add profile to list
    local profiles=$(dconf read "/org/gnome/terminal/legacy/profiles:/list" | tr -d '[]')
    if [ -z "$profiles" ]; then
      profiles="'$profile_id'"
    else
      profiles="$profiles, '$profile_id'"
    fi
    dconf write "/org/gnome/terminal/legacy/profiles:/list" "[$profiles]"
    
    # Set as default
    dconf write "/org/gnome/terminal/legacy/profiles:/default" "'$profile_id'"
    
    echo "GNOME Terminal configuration installed!"
  else
    echo "Terminal configuration not found at $config_path"
  fi
}

function install_konsole_config() {
  echo "Installing Konsole configuration..."
  
  local config_path="$(dirname "$0")/../core/terminal/linux.conf"
  if [ -f "$config_path" ]; then
    # Create Konsole profile directory
    mkdir -p "$HOME/.local/share/konsole"
    
    # Create profile file
    local profile_path="$HOME/.local/share/konsole/Perfect.profile"
    local colorscheme_path="$HOME/.local/share/konsole/Perfect.colorscheme"
    
    # Create profile
    cat > "$profile_path" << EOF
[Appearance]
ColorScheme=Perfect
Font=SauceCodePro Nerd Font,12,-1,5,50,0,0,0,0,0

[General]
Name=Perfect
Parent=FALLBACK/
EOF
    
    # Create color scheme
    cat > "$colorscheme_path" << EOF
[Background]
Color=$(grep "^background=" "$config_path" | cut -d "=" -f2)

[BackgroundIntense]
Color=$(grep "^background=" "$config_path" | cut -d "=" -f2)

[Foreground]
Color=$(grep "^foreground=" "$config_path" | cut -d "=" -f2)

[ForegroundIntense]
Color=$(grep "^foreground=" "$config_path" | cut -d "=" -f2)

[Color0]
Color=$(grep "^color0=" "$config_path" | cut -d "=" -f2)

[Color1]
Color=$(grep "^color1=" "$config_path" | cut -d "=" -f2)

[Color2]
Color=$(grep "^color2=" "$config_path" | cut -d "=" -f2)

[Color3]
Color=$(grep "^color3=" "$config_path" | cut -d "=" -f2)

[Color4]
Color=$(grep "^color4=" "$config_path" | cut -d "=" -f2)

[Color5]
Color=$(grep "^color5=" "$config_path" | cut -d "=" -f2)

[Color6]
Color=$(grep "^color6=" "$config_path" | cut -d "=" -f2)

[Color7]
Color=$(grep "^color7=" "$config_path" | cut -d "=" -f2)

[Color0Intense]
Color=$(grep "^color8=" "$config_path" | cut -d "=" -f2)

[Color1Intense]
Color=$(grep "^color9=" "$config_path" | cut -d "=" -f2)

[Color2Intense]
Color=$(grep "^color10=" "$config_path" | cut -d "=" -f2)

[Color3Intense]
Color=$(grep "^color11=" "$config_path" | cut -d "=" -f2)

[Color4Intense]
Color=$(grep "^color12=" "$config_path" | cut -d "=" -f2)

[Color5Intense]
Color=$(grep "^color13=" "$config_path" | cut -d "=" -f2)

[Color6Intense]
Color=$(grep "^color14=" "$config_path" | cut -d "=" -f2)

[Color7Intense]
Color=$(grep "^color15=" "$config_path" | cut -d "=" -f2)
EOF
    
    echo "Konsole configuration installed!"
  else
    echo "Terminal configuration not found at $config_path"
  fi
}

function install_xfce_terminal_config() {
  echo "Installing XFCE Terminal configuration..."
  
  local config_path="$(dirname "$0")/../core/terminal/linux.conf"
  if [ -f "$config_path" ]; then
    # Create XFCE Terminal config directory
    mkdir -p "$HOME/.config/xfce4/terminal"
    
    # Create config file
    local xfce_config="$HOME/.config/xfce4/terminal/terminalrc"
    
    # Backup existing config
    if [ -f "$xfce_config" ]; then
      cp "$xfce_config" "$xfce_config.backup"
    fi
    
    # Create new config
    cat > "$xfce_config" << EOF
[Configuration]
FontName=SauceCodePro Nerd Font 12
ColorForeground=$(grep "^foreground=" "$config_path" | cut -d "=" -f2)
ColorBackground=$(grep "^background=" "$config_path" | cut -d "=" -f2)
ColorCursor=$(grep "^cursor=" "$config_path" | cut -d "=" -f2)
ColorPalette=$(grep "^color0=" "$config_path" | cut -d "=" -f2);$(grep "^color1=" "$config_path" | cut -d "=" -f2);$(grep "^color2=" "$config_path" | cut -d "=" -f2);$(grep "^color3=" "$config_path" | cut -d "=" -f2);$(grep "^color4=" "$config_path" | cut -d "=" -f2);$(grep "^color5=" "$config_path" | cut -d "=" -f2);$(grep "^color6=" "$config_path" | cut -d "=" -f2);$(grep "^color7=" "$config_path" | cut -d "=" -f2);$(grep "^color8=" "$config_path" | cut -d "=" -f2);$(grep "^color9=" "$config_path" | cut -d "=" -f2);$(grep "^color10=" "$config_path" | cut -d "=" -f2);$(grep "^color11=" "$config_path" | cut -d "=" -f2);$(grep "^color12=" "$config_path" | cut -d "=" -f2);$(grep "^color13=" "$config_path" | cut -d "=" -f2);$(grep "^color14=" "$config_path" | cut -d "=" -f2);$(grep "^color15=" "$config_path" | cut -d "=" -f2)
EOF
    
    echo "XFCE Terminal configuration installed!"
  else
    echo "Terminal configuration not found at $config_path"
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
  mkdir -p "$HOME/.local/share/fonts"
  cp "$font_dir"/*.ttf "$HOME/.local/share/fonts/"
  
  # Update font cache
  fc-cache -f -v
  
  # Clean up
  rm -f "$font_zip"
  rm -rf "$font_dir"
  
  echo "Fonts installed successfully!"
}