#!/bin/bash
# Python add-on installation script for macOS

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
    echo -e "\ue73c Python $version (venv: $venv_name)"
  elif [ "$type" = "pinned" ]; then
    echo -e "\ue73c Python $version (pinned: $extra)"
  else
    echo -e "\ue73c Python $version"
  fi
fi

# Enhanced prompt with Python environment information
python_prompt() {
  # ANSI color codes
  local pale_yellow="\e[38;5;223m"
  local pale_hot_pink="\e[38;5;218m"
  local pale_bright_green="\e[38;5;156m"
  local very_pale_green="\e[38;5;194m"
  local pale_purple="\e[38;5;183m"
  local reset="\e[0m"
  local bold="\e[1m"
  
  # Get hostname and current directory
  local hostname=$(hostname)
  local curdir=$(basename "$PWD")
  if [ "$PWD" = "$HOME" ]; then
    curdir="~"
  elif [[ "$PWD" == "$HOME/"* ]]; then
    curdir="~/${PWD#$HOME/}"
  fi
  
  # Determine if running as admin
  local prompt_emoji="✨"
  if [ "$(id -u)" = "0" ]; then
    prompt_emoji="🔥"
  fi
  
  # Build the prompt
  local prompt_string="$prompt_emoji $bold$pale_yellow$hostname$reset $bold$pale_hot_pink$curdir$reset"
  
  # Add Python environment information
  local python_info=$(python_env_detect)
  if [ -n "$python_info" ]; then
    IFS=':' read -r type version extra <<< "$python_info"
    
    if [ "$type" = "venv" ]; then
      venv_name=$(basename "$extra")
      if [ "$venv_name" = ".venv" ]; then
        venv_name=$(basename "$(pwd)")
      fi
      prompt_string="$prompt_string $very_pale_green\ue73c$pale_bright_green:[$very_pale_green$venv_name$pale_bright_green]$reset"
    elif [ "$type" = "pinned" ]; then
      prompt_string="$prompt_string $very_pale_green\ue73c$pale_bright_green:[$very_pale_green$version$pale_bright_green]$reset"
    fi
  fi
  
  # Add Git information if available
  if command -v git >/dev/null 2>&1; then
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --always 2>/dev/null)
      local git_status=""
      
      # Count modified files
      local modified=$(git status --porcelain 2>/dev/null | grep -E "^(M| M)" | wc -l)
      # Count untracked files
      local untracked=$(git status --porcelain 2>/dev/null | grep -E "^\?\?" | wc -l)
      # Get ahead/behind counts
      local ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
      local behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
      
      git_info=" $pale_purple\ueafc ($pale_yellow$branch$pale_purple)"
      if [ "$modified" -gt 0 ]; then git_info="$git_info+$modified"; fi
      if [ "$untracked" -gt 0 ]; then git_info="$git_info?"; fi
      if [ "$ahead" -gt 0 ]; then git_info="$git_info↑$ahead"; fi
      if [ "$behind" -gt 0 ]; then git_info="$git_info↓$behind"; fi
      
      prompt_string="$prompt_string$git_info$reset"
    fi
  fi
  
  echo -e "$prompt_string\n$bold❯$reset "
}

# Set the PS1 prompt to use our custom function
export PS1='$(python_prompt)'

# Add uv to PATH
if [ -d "$HOME/.cargo/bin" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi
EOF

  echo "Python installed successfully!"
}

# Call the installation function
install_python