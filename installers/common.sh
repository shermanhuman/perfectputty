#!/bin/bash
# Common installer functions for Unix-like systems

# Function to parse YAML files
function parse_yaml() {
  local yaml_file=$1
  local prefix=$2
  local s
  s='[[:space:]]*'
  w='[a-zA-Z0-9_]*'
  fs=$(echo @|tr @ '\034')
  
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" "$yaml_file" |
  awk -F$fs '{
    indent = length($1)/2;
    vname[indent] = $2;
    for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
      vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
      printf("%s%s%s=\"%s\"\n", "'"$prefix"'",vn,$2,$3);
    }
  }'
}

function create_default_config() {
  local config_path="$(dirname "$0")/../user-config.yaml"
  
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
}

function scan_addons() {
  local addons_dir="$(dirname "$0")/../addons"
  ADDONS=()
  ADDON_NAMES=()
  ADDON_DESCRIPTIONS=()
  ADDON_PLATFORMS=()
  
  if [ ! -d "$addons_dir" ]; then
    return
  fi
  
  for addon_dir in "$addons_dir"/*; do
    if [ -d "$addon_dir" ]; then
      local config_path="$addon_dir/config.yaml"
      if [ -f "$config_path" ]; then
        # Parse YAML file
        local prefix="config_"
        eval $(parse_yaml "$config_path" "$prefix")
        
        # Get values from parsed YAML
        local name="${config_name}"
        local description="${config_description}"
        
        # Handle platforms array
        local platforms=""
        for platform in $(grep -A10 "^platforms:" "$config_path" | grep -v "^platforms:" | grep "^  -" | cut -d "-" -f2- | xargs); do
          platforms="$platforms $platform"
        done
        
        ADDONS+=("$addon_dir")
        ADDON_NAMES+=("$name")
        ADDON_DESCRIPTIONS+=("$description")
        ADDON_PLATFORMS+=("$platforms")
      fi
    fi
  done
}

function present_addon_menu() {
  SELECTED_ADDONS=()
  
  if [ ${#ADDONS[@]} -eq 0 ]; then
    echo "No add-ons available."
    return
  fi
  
  echo
  echo "=== Available Add-ons ==="
  
  for i in "${!ADDONS[@]}"; do
    local platforms="${ADDON_PLATFORMS[$i]}"
    local is_compatible=false
    
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
        local index=$((num-1))
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
}

function install_selected_addons() {
  for i in "${!ADDONS[@]}"; do
    if [ "${SELECTED_ADDONS[$i]}" = "true" ]; then
      echo "Installing add-on: ${ADDON_NAMES[$i]}"
      local script_path="${ADDONS[$i]}/$OS.sh"
      if [ -f "$script_path" ]; then
        bash "$script_path"
      else
        echo "No installation script found for ${ADDON_NAMES[$i]} on $OS"
      fi
    fi
  done
}

function offer_tests() {
  echo
  echo -n "Would you like to run tests to verify your installation? (y/n): "
  read -r run_tests
  
  if [ "$run_tests" != "y" ]; then
    return
  fi
  
  local tests_path="$(dirname "$0")/../tests/run-tests.sh"
  if [ -f "$tests_path" ]; then
    bash "$tests_path"
  else
    echo "Tests not found at $tests_path"
  fi
}