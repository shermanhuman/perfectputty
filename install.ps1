# Perfect Environment Installer for Windows
# This script installs the Perfect environment configuration for Windows

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Warning "Please run as administrator for full functionality!"
  $continue = Read-Host "Continue anyway? (y/n)"
  if ($continue -ne "y") {
    exit
  }
}

# Source common and Windows-specific functions
. "$PSScriptRoot\installers\common.ps1"
. "$PSScriptRoot\installers\windows.ps1"

# Create default user-config.yaml if it doesn't exist
if (-not (Test-Path "$PSScriptRoot\user-config.yaml")) {
  Create-DefaultConfig
}

# Install core components
Write-Host "Installing core components..." -ForegroundColor Cyan
Install-ShellProfile
Install-TerminalConfig
Install-Fonts

# Scan and present add-ons
$Addons = Scan-Addons
$Selected = Present-AddonMenu -Addons $Addons
Install-SelectedAddons -Selected $Selected

# Offer to run tests
Offer-Tests

Write-Host "Installation complete!" -ForegroundColor Green