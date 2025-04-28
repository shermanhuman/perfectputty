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
echo "Available tests:"
echo "1. Color test - Shows all terminal colors"
echo "2. Unicode test - Tests Unicode character support"
echo "3. ASCII art - Displays ASCII art"
echo
echo "Enter test number to run (or 'q' to quit): "
read -r test_choice

case "$test_choice" in
  1)
    run_color_test
    ;;
  2)
    run_unicode_test
    ;;
  3)
    run_ascii_art
    ;;
  q|Q)
    exit 0
    ;;
  *)
    echo "Invalid choice."
    exit 1
    ;;
esac