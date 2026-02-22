#!/bin/bash

# Nerd Font Character Test
# Displays various symbols to verify Nerd Font support

# Define styles
BOLD="\033[1m"
RESET="\033[0m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"

echo -e "${BOLD}Nerd Font Character Test${RESET}"
echo "----------------------------------------"

# Powerline Symbols
echo -e "${CYAN}Powerline Symbols:${RESET}"
echo -e "Right Arrow: \ue0b0"
echo -e "Right Arrow Thin: \ue0b1"
echo -e "Left Arrow: \ue0b2"
echo -e "Left Arrow Thin: \ue0b3"
echo

# Devicons
echo -e "${GREEN}Devicons:${RESET}"
echo -e "GitHub: \ue709"
echo -e "Git: \ue702"
echo -e "Python: \ue73c"
echo -e "Node.js: \ue718"
echo -e "Linux: \ue712"
echo -e "Apple: \ue711"
echo -e "Windows: \ue70f"
echo

# Weather Icons
echo -e "${YELLOW}Weather Icons:${RESET}"
echo -e "Sun: \ue30d"
echo -e "Cloud: \ue312"
echo -e "Rain: \ue318"
echo

# Material Design
echo -e "${BLUE}Material Design:${RESET}"
echo -e "Folder: \ue5fe"
echo -e "File: \ue24d"
echo -e "Settings: \ue8b8"
echo -e "Search: \ue8b6"
echo

# Octicons
echo -e "${MAGENTA}Octicons:${RESET}"
echo -e "Code: \uf470"
echo -e "Branch: \uf418"
echo -e "Commit: \uf417"
echo

echo -e "${BOLD}If you see boxes or question marks, the font is not correctly installed or configured.${RESET}"
