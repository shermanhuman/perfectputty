#!/bin/bash
# Python add-on installation script for Linux

function install_python() {
  echo "Installing Python with uv (Astral Package Manager)..."
  
  # Check if uv is already installed
  if command -v uv &> /dev/null; then
    echo "uv is already installed"
  else
    # Install uv using the official installer
    echo "Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    # Add uv to PATH for the current session
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Verify installation
    if command -v uv &> /dev/null; then
      echo "uv installed successfully!"
    else
      echo "Failed to install uv. Please install it manually."
      return 1
    fi
  fi
  
  # Install Python using uv
  echo "Installing latest Python version using uv..."
  uv python install
  
  # Add Python environment detection to shell profile
  cat >> "$HOME/.profile" << 'EOF'
# Python environment detection and initialization
python_env_detect() {
  # Check for active virtual environment
  if [ -n "$VIRTUAL_ENV" ]; then
    echo "venv:$(python --version 2>&1 | cut -d' ' -f2):$VIRTUAL_ENV"
    return
  fi
  
  # Check for .venv directory
  if [ -d ".venv" ] && [ -f ".venv/bin/python" ]; then
    version=$(.venv/bin/python --version 2>&1 | cut -d' ' -f2)
    echo "venv:$version:.venv"
    return
  fi
  
  # Check for .python-version file
  if [ -f ".python-version" ]; then
    requested=$(cat .python-version)
    version=$(python --version 2>&1 | cut -d' ' -f2)
    echo "pinned:$version:$requested"
    return
  fi
  
  # Default system Python
  version=$(python --version 2>&1 | cut -d' ' -f2)
  if [ -n "$version" ]; then
    echo "system:$version"
    return
  fi
}

# Initialize Python environment
python_info=$(python_env_detect)
if [ -n "$python_info" ]; then
  IFS=':' read -r type version extra <<< "$python_info"
  
  if [ "$type" = "venv" ]; then
    venv_name=$(basename "$extra")
    if [ "$venv_name" = ".venv" ]; then
      venv_name=$(basename "$(pwd)")
    fi
    echo "🐍 Python $version (venv: $venv_name)"
  elif [ "$type" = "pinned" ]; then
    echo "🐍 Python $version (pinned: $extra)"
  else
    echo "🐍 Python $version"
  fi
fi

# Add uv to PATH
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
EOF

  echo "Python installed successfully!"
}

# Call the installation function
install_python