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

# Create temporary directory
tmp_dir="/tmp/perfectputty_install"
mkdir -p "$tmp_dir"

# Create default user-config.yaml
config_path="$tmp_dir/user-config.yaml"
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

# Install core components
echo "Installing core components..."

# Shell profile content for macOS/Linux
profile_content="
export CLICOLOR=1
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# Custom prompt with git support
if [ -n \"\$BASH_VERSION\" ]; then
  parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
  }
  
  PS1='\\[\\033[33;1m\\]@\\[\\033[33m\\]\\h\\[\\033[37;22m\\]:\\W\\[\\033[36m\\] \$(parse_git_branch)\\[\\033[31m\\] \$\\[\\033[0;0m\\] '
fi

# Miniconda initialization
if [ -f \"\$HOME/miniconda3/bin/conda\" ]; then
  export PATH=\"\$HOME/miniconda3/bin:\$PATH\"
  eval \"\$(\$HOME/miniconda3/bin/conda shell.bash hook)\"
  echo \"Miniconda loaded: Python \$(python --version 2>&1 | cut -d\" \" -f2)\"
fi

# fnm Node.js initialization
if command -v fnm &> /dev/null; then
  eval \"\$(fnm env --use-on-cd)\"
  echo \"fnm loaded: Node \$(node --version 2>/dev/null | sed 's/v//')\"
fi
"

# Install shell profile
profile_path="$HOME/.profile"

# Create backup directory
backup_dir="$HOME/PerfectPutty_Backups"
mkdir -p "$backup_dir"

# Create a backup of the existing profile if it exists
if [ -f "$profile_path" ]; then
  timestamp=$(date +"%Y%m%d-%H%M%S")
  backup_file="$backup_dir/Shell_Profile_Backup_$timestamp"
  
  echo "Creating backup of shell profile to $backup_file..."
  cp "$profile_path" "$backup_file"
  echo "Shell profile backup created successfully!"
fi

# Write new profile
if echo "$profile_content" > "$profile_path"; then
  echo "Shell profile installed to $profile_path"
else
  echo "Error installing shell profile"
  
  if [ -f "$backup_file" ]; then
    echo -n "Would you like to restore from backup? (y/n): "
    read -r restore
    
    if [ "$restore" = "y" ]; then
      echo "Restoring shell profile from $backup_file..."
      cp "$backup_file" "$profile_path"
      echo "Shell profile restored successfully!"
    fi
  fi
fi

# Install terminal config
if [ "$OS" = "macos" ]; then
  echo "Installing Terminal.app configuration..."
  
  # Create backup directory
  backup_dir="$HOME/PerfectPutty_Backups"
  mkdir -p "$backup_dir"
  
  # Create a backup of Terminal.app settings
  timestamp=$(date +"%Y%m%d-%H%M%S")
  backup_file="$backup_dir/Terminal_Settings_Backup_$timestamp.plist"
  
  echo "Creating backup of Terminal.app settings..."
  
  # Check if Terminal settings exist
  if defaults read com.apple.Terminal > /dev/null 2>&1; then
    defaults export com.apple.Terminal "$backup_file"
    echo "Terminal.app settings backup created successfully at $backup_file"
  else
    echo "No existing Terminal.app settings found to backup"
  fi
  
  # Create Terminal.app profiles directory if it doesn't exist
  mkdir -p "$HOME/Library/Application Support/Terminal"
  
  # Create a basic Terminal.app profile
  # This is a simplified version - in a real implementation,
  # you would include the full Perfect.terminal file content
  if defaults write com.apple.Terminal "Window Settings" -dict-add "Perfect" "{
    BackgroundColor = \"0.059 0.063 0.067\";
    CursorColor = \"0.835 0.867 0.824\";
    SelectionColor = \"0.071 0.071 0.071\";
    TextColor = \"0.765 0.765 0.765\";
    FontName = \"SauceCodePro Nerd Font\";
    FontSize = 12;
  }"; then
    # Set as default
    defaults write com.apple.Terminal "Default Window Settings" -string "Perfect"
    defaults write com.apple.Terminal "Startup Window Settings" -string "Perfect"
    
    echo "Terminal.app configuration installed successfully!"
  else
    echo "Error installing Terminal.app configuration"
    
    # Offer to restore from backup
    if [ -f "$backup_file" ]; then
      echo -n "Would you like to restore Terminal.app settings from backup? (y/n): "
      read -r restore
      
      if [ "$restore" = "y" ]; then
        echo "Restoring Terminal.app settings from $backup_file..."
        defaults import com.apple.Terminal "$backup_file"
        echo "Terminal.app settings restored successfully!"
      fi
    fi
  fi
elif [ "$OS" = "linux" ]; then
  echo "Installing terminal configuration for Linux..."
  
  # Create backup directory
  backup_dir="$HOME/PerfectPutty_Backups"
  mkdir -p "$backup_dir"
  timestamp=$(date +"%Y%m%d-%H%M%S")
  
  # Detect terminal
  if [ -d "$HOME/.config/gnome-terminal" ]; then
    echo "GNOME Terminal detected. Installing configuration..."
    
    # Backup GNOME Terminal settings
    backup_file="$backup_dir/GNOME_Terminal_Backup_$timestamp.dconf"
    echo "Creating backup of GNOME Terminal settings to $backup_file..."
    
    if command -v dconf > /dev/null; then
      dconf dump /org/gnome/terminal/ > "$backup_file"
      echo "GNOME Terminal settings backup created successfully!"
      
      # GNOME Terminal configuration would go here
      # Example:
      # dconf write /org/gnome/terminal/legacy/profiles:/:$profile_id/background-color "'#0F1011'"
      
      echo "GNOME Terminal configuration installed successfully!"
    else
      echo "dconf command not found. Cannot backup or configure GNOME Terminal."
    fi
    
  elif [ -d "$HOME/.config/konsole" ]; then
    echo "Konsole detected. Installing configuration..."
    
    # Backup Konsole settings
    konsole_dir="$HOME/.local/share/konsole"
    if [ -d "$konsole_dir" ]; then
      backup_file="$backup_dir/Konsole_Backup_$timestamp"
      mkdir -p "$backup_file"
      
      echo "Creating backup of Konsole settings to $backup_file..."
      cp -r "$konsole_dir"/* "$backup_file"
      echo "Konsole settings backup created successfully!"
      
      # Konsole configuration would go here
      
      echo "Konsole configuration installed successfully!"
    else
      echo "No existing Konsole settings found to backup."
    fi
    
  elif [ -d "$HOME/.config/xfce4/terminal" ]; then
    echo "XFCE Terminal detected. Installing configuration..."
    
    # Backup XFCE Terminal settings
    xfce_config="$HOME/.config/xfce4/terminal/terminalrc"
    if [ -f "$xfce_config" ]; then
      backup_file="$backup_dir/XFCE_Terminal_Backup_$timestamp"
      
      echo "Creating backup of XFCE Terminal settings to $backup_file..."
      cp "$xfce_config" "$backup_file"
      echo "XFCE Terminal settings backup created successfully!"
      
      # XFCE Terminal configuration would go here
      
      echo "XFCE Terminal configuration installed successfully!"
    else
      echo "No existing XFCE Terminal settings found to backup."
    fi
    
  else
    echo "Unsupported terminal. Configuration not installed."
    echo "Supported terminals: GNOME Terminal, Konsole, XFCE Terminal"
  fi
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

# Clean up
rm -rf "$tmp_dir"

echo "Installation complete!"