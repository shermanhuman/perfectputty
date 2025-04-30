#!/bin/bash

# Test runner for Unix systems

function run_color_test() {
  bash "$(dirname "$0")/common/colortest.sh"
}

function run_unicode_test() {
  bash "$(dirname "$0")/common/unicode-test.sh"
}

function run_ascii_art() {
  for file in "$(dirname "$0")/common/ascii/"*.ascii; do
    cat "$file"
    echo
  done
}

# Main menu
while true; do
  clear
  echo "Available tests:"
  echo "1. Color test - Shows all terminal colors"
  echo "2. Unicode test - Tests Unicode character support"
  echo "3. ASCII art - Displays ASCII art"
  echo "q. Exit"
  echo
  echo -n "Enter test number to run: "
  read -r test_choice

  case "$test_choice" in
    1)
      run_color_test
      echo
      echo "Press Enter to return to menu..."
      read -r
      ;;
    2)
      run_unicode_test
      echo
      echo "Press Enter to return to menu..."
      read -r
      ;;
    3)
      run_ascii_art
      echo
      echo "Press Enter to return to menu..."
      read -r
      ;;
    q|Q)
      exit 0
      ;;
    *)
      echo "Invalid choice."
      sleep 2
      ;;
  esac
done