#!/bin/bash
# Node.js add-on installation script for macOS

function install_nodejs() {
  echo "Installing Node.js with fnm (Fast Node Manager)..."
  
  # Check if fnm is already installed
  if command -v fnm &> /dev/null; then
    echo "fnm is already installed"
  else
    # Install fnm using Homebrew if available, otherwise use curl
    if command -v brew &> /dev/null; then
      echo "Installing fnm using Homebrew..."
      brew install fnm
    else
      echo "Installing fnm using curl..."
      curl -fsSL https://fnm.vercel.app/install | bash
    fi
  fi
  
  # Add fnm initialization to shell profile
  if ! grep -q "fnm Node.js initialization" "$HOME/.profile"; then
    cat >> "$HOME/.profile" << EOF

# fnm Node.js initialization
if command -v fnm &> /dev/null; then
  eval "\$(fnm env --use-on-cd)"
  echo "fnm loaded: Node \$(node --version 2>/dev/null | sed 's/v//')"
fi
EOF
  fi
  
  # Source fnm to use it in the current script
  eval "$(fnm env)"
  
  # Install latest Node.js version
  echo "Installing latest Node.js version..."
  fnm install --latest
  fnm default latest
  
  echo "Node.js installed successfully!"
}

# Call the installation function
install_nodejs