#!/bin/bash
# Perfect Environment Installer for macOS
# This script installs the Perfect environment configuration for macOS
# Version: 2.0.6
# Generated on 2025-05-01

# Define color codes
PURPLE='\033[0;35m'   # 74569b - Headers, section titles
MINT='\033[0;32m'     # 96fbc7 - Success messages
LEMON='\033[0;33m'    # f7ffae - Warnings, prompts
PINK='\033[0;31m'     # ffb3cb - Errors
LAVENDER='\033[0;34m' # d8bfd8 - Info messages
NC='\033[0m'          # No Color

# Define repository information
REPO_OWNER="shermanhuman"
REPO_NAME="perfectputty"
BRANCH="master"
REPO_BASE_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH"

# Create a unique temporary directory
TEMP_DIR=$(mktemp -d)
if [ ! -d "$TEMP_DIR" ]; then
  echo -e "${PINK}Failed to create temporary directory${NC}"
  exit 1
fi
echo -e "${LAVENDER}Created temporary directory: $TEMP_DIR${NC}"

# Cleanup function
cleanup() {
  echo -e "${LAVENDER}Cleaning up temporary files...${NC}"
  rm -rf "$TEMP_DIR"
}

# Set trap to ensure cleanup on exit
trap cleanup EXIT

# Define file manifest
FILE_MANIFEST=(
    "core/profiles/shell_profile.sh"
    "core/terminal/macos.terminal"
    "core/color-schemes/perfect16.yaml"
    "core/sounds/pop.wav"
    "dist/shell-themes/perfect.toml"
    "addons/nodejs/config.yaml"
    "addons/nodejs/install-scripts/macos.sh"
    "addons/python/config.yaml"
    "addons/python/install-scripts/macos.sh"
    "tests/run-tests.sh"
    "tests/common/colortest.sh"
    "tests/common/unicode-test.sh"
    "tests/common/ascii/big.ascii"
    "tests/common/ascii/circle.ascii"
    "tests/common/ascii/future.ascii"
    "tests/common/ascii/mike.ascii"
    "tests/common/ascii/pagga.ascii"
)

# Show download progress function
show_download_progress() {
  local current_file="$1"
  local total_files="$2"
  local file_path="$3"
  local file_size="$4"
  
  # Braille spinner characters for a more elegant animation
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local spinner_index=$((current_file % 10))
  local spinner=${spinstr:$spinner_index:1}
  
  # Format the status line according to user's preferred format
  local status_line="$spinner [$current_file/$total_files] Downloading ($file_size) $file_path"
  
  # Clear the line and write the new status
  printf "\r%-100s" " "
  printf "\r${PURPLE}%s${NC}" "$status_line"
}

# Clean up on exit
trap cleanup EXIT

# Download function with retry logic
download_file() {
  local file_path="$1"
  local current_file="$2"
  local total_files="$3"
  local output_path="$TEMP_DIR/$file_path"
  local url="$REPO_BASE_URL/$file_path"
  local max_retries=3
  local attempt=0
  local success=false
  
  # Create directory structure
  mkdir -p "$(dirname "$output_path")"
  
  # Try to get file size
  local file_size="unknown size"
  local size_info=$(curl -sI "$url" | grep -i "Content-Length")
  if [ -n "$size_info" ]; then
    local bytes=$(echo "$size_info" | awk '{print $2}' | tr -d '\r')
    file_size="$(echo "scale=2; $bytes/1024" | bc) KB"
  fi
  
  # Show download progress with single-line format
  show_download_progress "$current_file" "$total_files" "$file_path" "$file_size"
  
  while [ $attempt -lt $max_retries ] && [ "$success" = false ]; do
    attempt=$((attempt + 1))
    
    if curl -fsSL "$url" -o "$output_path" 2>/dev/null; then
      success=true
      # No need to show "Done!" as we're moving to the next file
    else
      if [ $attempt -lt $max_retries ]; then
        backoff=$((2 ** attempt))
        printf "\r%-100s" " "
        # Already using the warning symbol (⚠) for consistency with the error message style
        printf "\r${LEMON}⚠ [$current_file/$total_files] Failed, retrying in $backoff seconds... $file_path${NC}"
        sleep $backoff
      else
        printf "\r%-100s" " "
        printf "\r${PINK}❌ [$current_file/$total_files] Failed after $max_retries attempts: $file_path${NC}\n"
        return 1
      fi
    fi
  done
  
  return 0
}

# Addon registry
# nodejs
ADDON_NODEJS_NAME="Node.js"
ADDON_NODEJS_DESCRIPTION="JavaScript runtime environment with fnm version manager"
ADDON_NODEJS_PLATFORMS=("windows" "macos" "linux")
ADDON_NODEJS_HAS_STARSHIP_CONFIG=true
ADDON_NODEJS_STARSHIP_MODULE='$nodejs\'
ADDON_NODEJS_STARSHIP_CONFIG='[nodejs]
format = "[$symbol($version )]($style)"
symbol = " "
style = "bold green"'

# python
ADDON_PYTHON_NAME="Python"
ADDON_PYTHON_DESCRIPTION="Python environment with uv package manager"
ADDON_PYTHON_PLATFORMS=("windows" "macos" "linux")
ADDON_PYTHON_HAS_STARSHIP_CONFIG=true
ADDON_PYTHON_STARSHIP_MODULE='$python\'
ADDON_PYTHON_STARSHIP_CONFIG='[python]
format = "[$symbol($version )(\($virtualenv\) )]($style)"
symbol = " "
style = "bold blue"'



# Function to check if addon has Starship config
addon_has_starship_config() {
  local addon_name="$1"
  local var_name="ADDON_${addon_name^^}_HAS_STARSHIP_CONFIG"
  eval "echo \$$var_name"
}

# Function to get addon Starship module
addon_starship_module() {
  local addon_name="$1"
  local var_name="ADDON_${addon_name^^}_STARSHIP_MODULE"
  eval "echo \$$var_name"
}

# Function to get addon Starship config
addon_starship_config() {
  local addon_name="$1"
  local var_name="ADDON_${addon_name^^}_STARSHIP_CONFIG"
  eval "echo \$$var_name"
}

# Add Starship configuration for addon
add_starship_config() {
  local addon_name="$1"
  local starship_config_path="$HOME/.config/starship.toml"
  
  # Check if Starship is installed and configured
  if [ -f "$starship_config_path" ]; then
    # Check if addon has Starship config
    if [ "$(addon_has_starship_config "$addon_name")" = "true" ]; then
      echo -e "${PURPLE}Adding $addon_name configuration to Starship...${NC}"
      
      # Get addon module and config
      local addon_module=$(addon_starship_module "$addon_name")
      local addon_config=$(addon_starship_config "$addon_name")
      
      # Read the current config
      local current_config=$(cat "$starship_config_path")
      
      # Replace module placeholder
      local new_config="${current_config/\# ADDON_MODULES_PLACEHOLDER #/$addon_module
# ADDON_MODULES_PLACEHOLDER #}"
      
      # Add config
      new_config="${new_config/\# ADDON_CONFIGS_PLACEHOLDER #/$addon_config
# ADDON_CONFIGS_PLACEHOLDER #}"
      
      # Write the new config
      echo "$new_config" > "$starship_config_path"
      
      echo -e "${MINT}$addon_name configuration added to Starship successfully!${NC}"
    fi
  fi
}

# Download all files
TOTAL_FILES=${#FILE_MANIFEST[@]}
CURRENT_FILE=0
FAILED_FILES=0

# Add a blank line for the download progress
echo ""

for file_path in "${FILE_MANIFEST[@]}"; do
  CURRENT_FILE=$((CURRENT_FILE + 1))
  
  if ! download_file "$file_path" "$CURRENT_FILE" "$TOTAL_FILES"; then
    FAILED_FILES=$((FAILED_FILES + 1))
  fi
  
  # Small delay to make the spinner animation visible
  sleep 0.05
done

# Clear the progress line when done
printf "\r%-100s\r" " "

# Check if any downloads failed
if [ $FAILED_FILES -gt 0 ]; then
  # Use the warning symbol (⚠) for consistency with the error message style
  echo -e "${PINK}⚠ $FAILED_FILES files failed to download. Aborting installation.${NC}"
  exit 1
fi

# Use the six dot braille character (⠿) in the success message
echo -e "${MINT}⠿ All files downloaded successfully!${NC}"

# Create default user-config.yaml
config_path="$TEMP_DIR/user-config.yaml"
cat > "$config_path" << EOF
# Global user configuration
colorScheme: Perfect16
font:
  family: SauceCodePro Nerd Font
  size: 12
terminal:
  scrollback: 10000
shell:
  theme: perfect
EOF
echo -e "${MINT}Created default user configuration at $config_path${NC}"

# Install core components
echo -e "${PURPLE}Installing core components...${NC}"

# Install shell profile
profile_path="$HOME/.profile"

# Create backup directory
backup_dir="$HOME/PerfectPutty_Backups"
mkdir -p "$backup_dir"

# Create a backup of the existing profile if it exists
if [ -f "$profile_path" ]; then
  timestamp=$(date +"%Y%m%d-%H%M%S")
  backup_file="$backup_dir/Shell_Profile_Backup_$timestamp"
  
  echo -e "${PURPLE}Creating backup of shell profile to $backup_file...${NC}"
  cp "$profile_path" "$backup_file"
  echo -e "${MINT}Shell profile backup created successfully!${NC}"
fi

# Read profile template
template_path="$TEMP_DIR/core/profiles/shell_profile.sh"
profile_content=$(cat "$template_path")

# Write new profile
if echo "$profile_content" > "$profile_path"; then
  echo -e "${MINT}Shell profile installed to $profile_path${NC}"
else
  echo -e "${PINK}Error installing shell profile${NC}"
  
  if [ -f "$backup_file" ]; then
    echo -n "Would you like to restore from backup? (y/n): "
    read -r restore
    
    if [ "$restore" = "y" ]; then
      echo -e "${LEMON}Restoring shell profile from $backup_file...${NC}"
      cp "$backup_file" "$profile_path"
      echo -e "${MINT}Shell profile restored successfully!${NC}"
    fi
  fi
fi

# Install terminal config
echo -e "${PURPLE}Installing Terminal.app configuration...${NC}"

# Create backup of Terminal.app settings
timestamp=$(date +"%Y%m%d-%H%M%S")
backup_file="$backup_dir/Terminal_Settings_Backup_$timestamp.plist"

echo -e "${PURPLE}Creating backup of Terminal.app settings...${NC}"

# Check if Terminal settings exist
if defaults read com.apple.Terminal > /dev/null 2>&1; then
  defaults export com.apple.Terminal "$backup_file"
  echo -e "${MINT}Terminal.app settings backup created successfully at $backup_file${NC}"
else
  echo -e "${LEMON}No existing Terminal.app settings found to backup${NC}"
fi

# Create Terminal.app profiles directory if it doesn't exist
mkdir -p "$HOME/Library/Application Support/Terminal"

# Create a basic Terminal.app profile
terminal_path="$TEMP_DIR/core/terminal/macos.terminal"
if [ -f "$terminal_path" ]; then
  # Copy terminal configuration
  cp "$terminal_path" "$HOME/Library/Application Support/Terminal/Perfect.terminal"
  
  # Set as default
  if defaults write com.apple.Terminal "Default Window Settings" -string "Perfect" && \
     defaults write com.apple.Terminal "Startup Window Settings" -string "Perfect"; then
    echo -e "${MINT}Terminal.app configuration installed successfully!${NC}"
  else
    echo -e "${PINK}Error installing Terminal.app configuration${NC}"
    
    # Offer to restore from backup
    if [ -f "$backup_file" ]; then
      echo -n "Would you like to restore Terminal.app settings from backup? (y/n): "
      read -r restore
      
      if [ "$restore" = "y" ]; then
        echo -e "${LEMON}Restoring Terminal.app settings from $backup_file...${NC}"
        defaults import com.apple.Terminal "$backup_file"
        echo -e "${MINT}Terminal.app settings restored successfully!${NC}"
      fi
    fi
  fi
else
  echo -e "${PINK}Terminal.app configuration not found at $terminal_path${NC}"
fi

# Install Starship
echo -e "${PURPLE}Installing Starship...${NC}"

# Check OS and install accordingly
if command -v brew &> /dev/null; then
  brew install starship
elif command -v curl &> /dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
elif command -v wget &> /dev/null; then
  wget -qO- https://starship.rs/install.sh | sh -s -- -y
else
  echo -e "${PINK}Error: Neither curl nor wget is available. Cannot install Starship.${NC}"
fi

# Verify installation
if command -v starship &> /dev/null; then
  echo -e "${MINT}Starship installed successfully!${NC}"
  
  # Get theme name from config
  theme_name="perfect"
  
  # Copy theme file
  theme_path="$TEMP_DIR/dist/shell-themes/$theme_name.toml"
  theme_dest_path="$HOME/.config"
  
  # Create config directory if it doesn't exist
  mkdir -p "$theme_dest_path"
  
  # Copy theme file
  cp "$theme_path" "$theme_dest_path/starship.toml"
  
  # Update shell profile to use Starship
  if [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
    echo -e "\n# Using Starship for prompt\neval \"\$(starship init zsh)\"" >> "$profile_path"
  else
    echo -e "\n# Using Starship for prompt\neval \"\$(starship init bash)\"" >> "$profile_path"
  fi
  
  echo -e "${MINT}Starship configured successfully!${NC}"
else
  echo -e "${LEMON}Starship installation failed. Using fallback prompt.${NC}"
fi

# Install fonts
echo -n "Would you like to install the SauceCodePro Nerd Font? (y/n): "
read -r install_fonts

if [ "$install_fonts" = "y" ]; then
  echo -e "${PURPLE}Downloading SauceCodePro Nerd Font...${NC}"
  font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip"
  font_zip="/tmp/SauceCodePro.zip"
  font_dir="/tmp/SauceCodePro"
  
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
  
  echo -e "${MINT}Fonts installed successfully!${NC}"
fi

# Process add-ons
echo -n "Would you like to install add-ons? (y/n): "
read -r install_addons

if [ "$install_addons" = "y" ]; then
  addons_dir="$TEMP_DIR/addons"
  ADDONS=()
  ADDON_NAMES=()
  ADDON_DESCRIPTIONS=()
  ADDON_PLATFORMS=()
  
  # Scan add-ons
  if [ -d "$addons_dir" ]; then
    for addon_dir in "$addons_dir"/*; do
      if [ -d "$addon_dir" ]; then
        config_path="$addon_dir/config.yaml"
        if [ -f "$config_path" ]; then
          name=$(grep "^name:" "$config_path" | cut -d ":" -f2- | xargs)
          description=$(grep "^description:" "$config_path" | cut -d ":" -f2- | xargs)
          platforms=$(grep -A10 "^platforms:" "$config_path" | grep -v "^platforms:" | grep "^  -" | cut -d "-" -f2- | xargs)
          
          ADDONS+=("$addon_dir")
          ADDON_NAMES+=("$name")
          ADDON_DESCRIPTIONS+=("$description")
          ADDON_PLATFORMS+=("$platforms")
        fi
      fi
    done
  fi
  
  # Present add-on menu
  SELECTED_ADDONS=()
  
  if [ ${#ADDONS[@]} -eq 0 ]; then
    echo -e "${LEMON}No add-ons available.${NC}"
  else
    echo -e "\n${PURPLE}=== Available Add-ons ===${NC}"
    
    for i in "${!ADDONS[@]}"; do
      platforms="${ADDON_PLATFORMS[$i]}"
      is_compatible=false
      
      if [[ "$platforms" == *"macos"* ]]; then
        is_compatible=true
      fi
      
      if [ "$is_compatible" = true ]; then
        echo "[ ] $((i+1)). ${ADDON_NAMES[$i]} - ${ADDON_DESCRIPTIONS[$i]}"
        SELECTED_ADDONS+=("false")
      fi
    done
    
    while true; do
      echo
      echo -n "Enter numbers to toggle selection (e.g., '1 3'), or press Enter to continue: "
      read -r input
      
      if [ -z "$input" ]; then
        break
      fi
      
      for num in $input; do
        if [[ "$num" =~ ^[0-9]+$ ]]; then
          index=$((num-1))
          if [ $index -ge 0 ] && [ $index -lt ${#ADDONS[@]} ]; then
            if [ "${SELECTED_ADDONS[$index]}" = "true" ]; then
              SELECTED_ADDONS[$index]="false"
              echo "[ ] $((index+1)). ${ADDON_NAMES[$index]}"
            else
              SELECTED_ADDONS[$index]="true"
              echo "[x] $((index+1)). ${ADDON_NAMES[$index]}"
            fi
          fi
        fi
      done
    done
    
    # Install selected add-ons
    for i in "${!ADDONS[@]}"; do
      if [ "${SELECTED_ADDONS[$i]}" = "true" ]; then
        echo -e "${PURPLE}Installing add-on: ${ADDON_NAMES[$i]}${NC}"
        script_path="${ADDONS[$i]}/install-scripts/macos.sh"
        if [ -f "$script_path" ]; then
          bash "$script_path"
          
          # Add Starship configuration if available
          addon_name=$(basename "${ADDONS[$i]}")
          add_starship_config "$addon_name"
        else
          echo -e "${LEMON}No installation script found for ${ADDON_NAMES[$i]} on macOS${NC}"
        fi
      fi
    done
  fi
fi

# Offer to run tests
echo
echo -n "Would you like to run tests to verify your installation? (y/n): "
read -r run_tests

if [ "$run_tests" = "y" ]; then
  tests_path="$TEMP_DIR/tests/run-tests.sh"
  if [ -f "$tests_path" ]; then
    bash "$tests_path"
  else
    echo -e "${LEMON}Tests not found at $tests_path${NC}"
  fi
fi

echo -e "${MINT}Installation complete!${NC}"