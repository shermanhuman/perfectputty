#!/bin/bash
# Miniconda add-on installation script for Linux

function install_miniconda() {
  local install_dir="$HOME/miniconda3"
  
  echo "Installing Miniconda..."
  
  # Check if already installed
  if [ -f "$install_dir/bin/conda" ]; then
    echo "Miniconda already installed at $install_dir"
    return
  fi
  
  # Download and install Miniconda
  echo "Downloading Miniconda installer..."
  local installer_path="/tmp/miniconda_installer.sh"
  curl -fsSL "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -o "$installer_path"
  
  echo "Installing Miniconda to $install_dir..."
  bash "$installer_path" -b -p "$install_dir"
  
  # Add to shell profile
  echo "# Miniconda initialization" >> "$HOME/.profile"
  echo 'export PATH="$HOME/miniconda3/bin:$PATH"' >> "$HOME/.profile"
  echo 'if [ -f "$HOME/miniconda3/bin/conda" ]; then' >> "$HOME/.profile"
  echo '  eval "$($HOME/miniconda3/bin/conda shell.bash hook)"' >> "$HOME/.profile"
  echo '  echo "Miniconda loaded: Python $(python --version 2>&1 | cut -d" " -f2)"' >> "$HOME/.profile"
  echo 'fi' >> "$HOME/.profile"
  
  # Clean up
  rm -f "$installer_path"
  
  echo "Miniconda installed successfully!"
}

# Call the installation function
install_miniconda