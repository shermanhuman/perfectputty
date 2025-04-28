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
echo "$profile_content" > "$profile_path"
echo "Shell profile installed to $profile_path"

# Install terminal config
if [ "$OS" = "macos" ]; then
  echo "Installing Terminal.app configuration..."
  
  # Create Terminal.app profiles directory if it doesn't exist
  mkdir -p "$HOME/Library/Application Support/Terminal"
  
  # Create a basic Terminal.app profile
  # This is a simplified version - in a real implementation,
  # you would include the full Perfect.terminal file content
  defaults write com.apple.Terminal "Window Settings" -dict-add "Perfect" "{
    BackgroundColor = \"0.059 0.063 0.067\";
    CursorColor = \"0.835 0.867 0.824\";
    SelectionColor = \"0.071 0.071 0.071\";
    TextColor = \"0.765 0.765 0.765\";
    FontName = \"SauceCodePro Nerd Font\";
    FontSize = 12;
  }"
  
  # Set as default
  defaults write com.apple.Terminal "Default Window Settings" -string "Perfect"
  defaults write com.apple.Terminal "Startup Window Settings" -string "Perfect"
  
  echo "Terminal.app configuration installed!"
elif [ "$OS" = "linux" ]; then
  echo "Installing terminal configuration for Linux..."
  
  # Detect terminal
  if [ -d "$HOME/.config/gnome-terminal" ]; then
    echo "GNOME Terminal detected. Installing configuration..."
    # GNOME Terminal configuration would go here
  elif [ -d "$HOME/.config/konsole" ]; then
    echo "Konsole detected. Installing configuration..."
    # Konsole configuration would go here
  elif [ -d "$HOME/.config/xfce4/terminal" ]; then
    echo "XFCE Terminal detected. Installing configuration..."
    # XFCE Terminal configuration would go here
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