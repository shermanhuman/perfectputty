#!/bin/bash
# Perfect Environment Installer for Unix-like systems (macOS and Linux)
# This script installs the Perfect environment configuration

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Define repository information
REPO_OWNER="shermanhuman"
REPO_NAME="perfectputty"
BRANCH="master"
REPO_BASE_URL="https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$BRANCH"

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
else
  echo -e "${RED}Unsupported operating system: $OSTYPE${NC}"
  exit 1
fi

# Create a unique temporary directory
TEMP_DIR=$(mktemp -d)
if [ ! -d "$TEMP_DIR" ]; then
  echo -e "${RED}Failed to create temporary directory${NC}"
  exit 1
fi
echo -e "${GRAY}Created temporary directory: $TEMP_DIR${NC}"

# Cleanup function
cleanup() {
  echo -e "${GRAY}Cleaning up temporary files...${NC}"
  rm -rf "$TEMP_DIR"
}

# Set trap to ensure cleanup on exit
trap cleanup EXIT

# Define file manifest
FILE_MANIFEST=(
  # Core files
  "core/profiles/shell_profile.sh"
  "core/terminal/macos.terminal"
  "core/terminal/linux.conf"
  "core/colors/perfect16.yaml"
  "core/sounds/pop.wav"
  
  # Add-on files
  "addons/python/config.yaml"
  "addons/python/macos.sh"
  "addons/python/linux.sh"
  "addons/nodejs/config.yaml"
  "addons/nodejs/macos.sh"
  "addons/nodejs/linux.sh"
  
  # Test files
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
  
  # Spinner characters
  local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local spinner_index=$((current_file % 10))
  local spinner=${spinstr:$spinner_index:1}
  
  # Format the status line according to user's preferred format
  local status_line="$spinner [$current_file/$total_files] Downloading ($file_size) $file_path"
  
  # Clear the line and write the new status
  printf "\r%-100s" " "
  printf "\r${CYAN}%s${NC}" "$status_line"
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
        printf "\r${YELLOW}⚠ [$current_file/$total_files] Failed, retrying in $backoff seconds... $file_path${NC}"
        sleep $backoff
      else
        printf "\r%-100s" " "
        printf "\r${RED}❌ [$current_file/$total_files] Failed after $max_retries attempts: $file_path${NC}\n"
        return 1
      fi
    fi
  done
  
  return 0
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
  echo -e "${RED}$FAILED_FILES files failed to download. Aborting installation.${NC}"
  exit 1
fi

echo -e "${GREEN}All files downloaded successfully!${NC}"

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
EOF
echo -e "${GREEN}Created default user configuration at $config_path${NC}"

# Install core components
echo -e "${CYAN}Installing core components...${NC}"

# Install shell profile
profile_path="$HOME/.profile"

# Create backup directory
backup_dir="$HOME/PerfectPutty_Backups"
mkdir -p "$backup_dir"

# Create a backup of the existing profile if it exists
if [ -f "$profile_path" ]; then
  timestamp=$(date +"%Y%m%d-%H%M%S")
  backup_file="$backup_dir/Shell_Profile_Backup_$timestamp"
  
  echo -e "${CYAN}Creating backup of shell profile to $backup_file...${NC}"
  cp "$profile_path" "$backup_file"
  echo -e "${GREEN}Shell profile backup created successfully!${NC}"
fi

# Read profile template
template_path="$TEMP_DIR/core/profiles/shell_profile.sh"
profile_content=$(cat "$template_path")

# Write new profile
if echo "$profile_content" > "$profile_path"; then
  echo -e "${GREEN}Shell profile installed to $profile_path${NC}"
else
  echo -e "${RED}Error installing shell profile${NC}"
  
  if [ -f "$backup_file" ]; then
    echo -n "Would you like to restore from backup? (y/n): "
    read -r restore
    
    if [ "$restore" = "y" ]; then
      echo -e "${YELLOW}Restoring shell profile from $backup_file...${NC}"
      cp "$backup_file" "$profile_path"
      echo -e "${GREEN}Shell profile restored successfully!${NC}"
    fi
  fi
fi

# Install terminal config
if [ "$OS" = "macos" ]; then
  echo -e "${CYAN}Installing Terminal.app configuration...${NC}"
  
  # Create backup of Terminal.app settings
  timestamp=$(date +"%Y%m%d-%H%M%S")
  backup_file="$backup_dir/Terminal_Settings_Backup_$timestamp.plist"
  
  echo -e "${CYAN}Creating backup of Terminal.app settings...${NC}"
  
  # Check if Terminal settings exist
  if defaults read com.apple.Terminal > /dev/null 2>&1; then
    defaults export com.apple.Terminal "$backup_file"
    echo -e "${GREEN}Terminal.app settings backup created successfully at $backup_file${NC}"
  else
    echo -e "${YELLOW}No existing Terminal.app settings found to backup${NC}"
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
      echo -e "${GREEN}Terminal.app configuration installed successfully!${NC}"
    else
      echo -e "${RED}Error installing Terminal.app configuration${NC}"
      
      # Offer to restore from backup
      if [ -f "$backup_file" ]; then
        echo -n "Would you like to restore Terminal.app settings from backup? (y/n): "
        read -r restore
        
        if [ "$restore" = "y" ]; then
          echo -e "${YELLOW}Restoring Terminal.app settings from $backup_file...${NC}"
          defaults import com.apple.Terminal "$backup_file"
          echo -e "${GREEN}Terminal.app settings restored successfully!${NC}"
        fi
      fi
    fi
  else
    echo -e "${RED}Terminal.app configuration not found at $terminal_path${NC}"
  fi
elif [ "$OS" = "linux" ]; then
  echo -e "${CYAN}Installing terminal configuration for Linux...${NC}"
  
  # Create backup directory
  backup_dir="$HOME/PerfectPutty_Backups"
  mkdir -p "$backup_dir"
  timestamp=$(date +"%Y%m%d-%H%M%S")
  
  # Detect terminal
  if [ -d "$HOME/.config/gnome-terminal" ]; then
    echo -e "${CYAN}GNOME Terminal detected. Installing configuration...${NC}"
    
    # Backup GNOME Terminal settings
    backup_file="$backup_dir/GNOME_Terminal_Backup_$timestamp.dconf"
    echo -e "${CYAN}Creating backup of GNOME Terminal settings to $backup_file...${NC}"
    
    if command -v dconf > /dev/null; then
      dconf dump /org/gnome/terminal/ > "$backup_file"
      echo -e "${GREEN}GNOME Terminal settings backup created successfully!${NC}"
      
      # GNOME Terminal configuration
      terminal_conf="$TEMP_DIR/core/terminal/linux.conf"
      if [ -f "$terminal_conf" ]; then
        # Create a new profile
        profile_id=$(uuidgen)
        dconf_path="/org/gnome/terminal/legacy/profiles:/:$profile_id"
        
        # Load colors from config
        background=$(grep "^background=" "$terminal_conf" | cut -d "=" -f2)
        foreground=$(grep "^foreground=" "$terminal_conf" | cut -d "=" -f2)
        
        # Set profile settings
        dconf write "$dconf_path/visible-name" "'Perfect'"
        dconf write "$dconf_path/background-color" "'$background'"
        dconf write "$dconf_path/foreground-color" "'$foreground'"
        dconf write "$dconf_path/use-theme-colors" "false"
        
        # Add profile to list
        profiles=$(dconf read "/org/gnome/terminal/legacy/profiles:/list" | tr -d '[]')
        if [ -z "$profiles" ]; then
          profiles="'$profile_id'"
        else
          profiles="$profiles, '$profile_id'"
        fi
        dconf write "/org/gnome/terminal/legacy/profiles:/list" "[$profiles]"
        
        # Set as default
        dconf write "/org/gnome/terminal/legacy/profiles:/default" "'$profile_id'"
        
        echo -e "${GREEN}GNOME Terminal configuration installed successfully!${NC}"
      else
        echo -e "${RED}Linux terminal configuration not found at $terminal_conf${NC}"
      fi
    else
      echo -e "${RED}dconf command not found. Cannot backup or configure GNOME Terminal.${NC}"
    fi
    
  elif [ -d "$HOME/.config/konsole" ]; then
    echo -e "${CYAN}Konsole detected. Installing configuration...${NC}"
    
    # Backup Konsole settings
    konsole_dir="$HOME/.local/share/konsole"
    if [ -d "$konsole_dir" ]; then
      backup_file="$backup_dir/Konsole_Backup_$timestamp"
      mkdir -p "$backup_file"
      
      echo -e "${CYAN}Creating backup of Konsole settings to $backup_file...${NC}"
      cp -r "$konsole_dir"/* "$backup_file" 2>/dev/null
      echo -e "${GREEN}Konsole settings backup created successfully!${NC}"
      
      # Konsole configuration
      terminal_conf="$TEMP_DIR/core/terminal/linux.conf"
      if [ -f "$terminal_conf" ]; then
        # Create Konsole profile directory
        mkdir -p "$HOME/.local/share/konsole"
        
        # Create profile file
        profile_path="$HOME/.local/share/konsole/Perfect.profile"
        colorscheme_path="$HOME/.local/share/konsole/Perfect.colorscheme"
        
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
Color=$(grep "^background=" "$terminal_conf" | cut -d "=" -f2)

[BackgroundIntense]
Color=$(grep "^background=" "$terminal_conf" | cut -d "=" -f2)

[Foreground]
Color=$(grep "^foreground=" "$terminal_conf" | cut -d "=" -f2)

[ForegroundIntense]
Color=$(grep "^foreground=" "$terminal_conf" | cut -d "=" -f2)

[Color0]
Color=$(grep "^color0=" "$terminal_conf" | cut -d "=" -f2)

[Color1]
Color=$(grep "^color1=" "$terminal_conf" | cut -d "=" -f2)

[Color2]
Color=$(grep "^color2=" "$terminal_conf" | cut -d "=" -f2)

[Color3]
Color=$(grep "^color3=" "$terminal_conf" | cut -d "=" -f2)

[Color4]
Color=$(grep "^color4=" "$terminal_conf" | cut -d "=" -f2)

[Color5]
Color=$(grep "^color5=" "$terminal_conf" | cut -d "=" -f2)

[Color6]
Color=$(grep "^color6=" "$terminal_conf" | cut -d "=" -f2)

[Color7]
Color=$(grep "^color7=" "$terminal_conf" | cut -d "=" -f2)

[Color0Intense]
Color=$(grep "^color8=" "$terminal_conf" | cut -d "=" -f2)

[Color1Intense]
Color=$(grep "^color9=" "$terminal_conf" | cut -d "=" -f2)

[Color2Intense]
Color=$(grep "^color10=" "$terminal_conf" | cut -d "=" -f2)

[Color3Intense]
Color=$(grep "^color11=" "$terminal_conf" | cut -d "=" -f2)

[Color4Intense]
Color=$(grep "^color12=" "$terminal_conf" | cut -d "=" -f2)

[Color5Intense]
Color=$(grep "^color13=" "$terminal_conf" | cut -d "=" -f2)

[Color6Intense]
Color=$(grep "^color14=" "$terminal_conf" | cut -d "=" -f2)

[Color7Intense]
Color=$(grep "^color15=" "$terminal_conf" | cut -d "=" -f2)
EOF
        
        echo -e "${GREEN}Konsole configuration installed successfully!${NC}"
      else
        echo -e "${RED}Linux terminal configuration not found at $terminal_conf${NC}"
      fi
    else
      echo -e "${YELLOW}No existing Konsole settings found to backup.${NC}"
    fi
    
  elif [ -d "$HOME/.config/xfce4/terminal" ]; then
    echo -e "${CYAN}XFCE Terminal detected. Installing configuration...${NC}"
    
    # Backup XFCE Terminal settings
    xfce_config="$HOME/.config/xfce4/terminal/terminalrc"
    if [ -f "$xfce_config" ]; then
      backup_file="$backup_dir/XFCE_Terminal_Backup_$timestamp"
      
      echo -e "${CYAN}Creating backup of XFCE Terminal settings to $backup_file...${NC}"
      cp "$xfce_config" "$backup_file"
      echo -e "${GREEN}XFCE Terminal settings backup created successfully!${NC}"
      
      # XFCE Terminal configuration
      terminal_conf="$TEMP_DIR/core/terminal/linux.conf"
      if [ -f "$terminal_conf" ]; then
        # Create XFCE Terminal config directory
        mkdir -p "$HOME/.config/xfce4/terminal"
        
        # Create config file
        cat > "$xfce_config" << EOF
[Configuration]
FontName=SauceCodePro Nerd Font 12
ColorForeground=$(grep "^foreground=" "$terminal_conf" | cut -d "=" -f2)
ColorBackground=$(grep "^background=" "$terminal_conf" | cut -d "=" -f2)
ColorCursor=$(grep "^cursor=" "$terminal_conf" | cut -d "=" -f2)
ColorPalette=$(grep "^color0=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color1=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color2=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color3=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color4=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color5=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color6=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color7=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color8=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color9=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color10=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color11=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color12=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color13=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color14=" "$terminal_conf" | cut -d "=" -f2);$(grep "^color15=" "$terminal_conf" | cut -d "=" -f2)
EOF
        
        echo -e "${GREEN}XFCE Terminal configuration installed successfully!${NC}"
      else
        echo -e "${RED}Linux terminal configuration not found at $terminal_conf${NC}"
      fi
    else
      echo -e "${YELLOW}No existing XFCE Terminal settings found to backup.${NC}"
    fi
    
  else
    echo -e "${YELLOW}Unsupported terminal. Configuration not installed.${NC}"
    echo -e "${YELLOW}Supported terminals: GNOME Terminal, Konsole, XFCE Terminal${NC}"
  fi
fi

# Install fonts
echo -n "Would you like to install the SauceCodePro Nerd Font? (y/n): "
read -r install_fonts

if [ "$install_fonts" = "y" ]; then
  echo -e "${CYAN}Downloading SauceCodePro Nerd Font...${NC}"
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
  
  echo -e "${GREEN}Fonts installed successfully!${NC}"
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
    echo -e "${YELLOW}No add-ons available.${NC}"
  else
    echo -e "\n${CYAN}=== Available Add-ons ===${NC}"
    
    for i in "${!ADDONS[@]}"; do
      platforms="${ADDON_PLATFORMS[$i]}"
      is_compatible=false
      
      if [[ "$OS" == "macos" && "$platforms" == *"macos"* ]]; then
        is_compatible=true
      elif [[ "$OS" == "linux" && "$platforms" == *"linux"* ]]; then
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
        echo -e "${CYAN}Installing add-on: ${ADDON_NAMES[$i]}${NC}"
        script_path="${ADDONS[$i]}/$OS.sh"
        if [ -f "$script_path" ]; then
          bash "$script_path"
        else
          echo -e "${YELLOW}No installation script found for ${ADDON_NAMES[$i]} on $OS${NC}"
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
    echo -e "${YELLOW}Tests not found at $tests_path${NC}"
  fi
fi

echo -e "${GREEN}Installation complete!${NC}"