# Perfect Environment Installer for Windows
# This script installs the Perfect environment configuration for Windows

# Determine if running remotely or locally
$isRemote = $MyInvocation.MyCommand.Path -eq ""
$repoUrl = "https://raw.githubusercontent.com/shermanhuman/perfectputty/master"

# Set base directory
if ($isRemote) {
    $baseDir = "$env:TEMP\perfectputty_install"
    if (-not (Test-Path $baseDir)) {
        New-Item -ItemType Directory -Path $baseDir -Force | Out-Null
    }
} else {
    $baseDir = $PSScriptRoot
}

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Warning "Please run as administrator for full functionality!"
  $continue = Read-Host "Continue anyway? (y/n)"
  if ($continue -ne "y") {
    exit
  }
}

# Function to download a file if running remotely
function Get-RemoteFile {
    param (
        [string]$RelativePath,
        [string]$OutputPath
    )
    
    if ($isRemote) {
        $url = "$repoUrl/$RelativePath"
        Write-Host "Downloading $url..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $url -OutFile $OutputPath
    }
}

# Create necessary directories
if ($isRemote) {
    New-Item -ItemType Directory -Path "$baseDir\installers" -Force | Out-Null
}

# Download or source common and Windows-specific functions
$commonPath = "$baseDir\installers\common.ps1"
$windowsPath = "$baseDir\installers\windows.ps1"

if ($isRemote) {
    Get-RemoteFile -RelativePath "installers/common.ps1" -OutputPath $commonPath
    Get-RemoteFile -RelativePath "installers/windows.ps1" -OutputPath $windowsPath
}

# Source the modules
. $commonPath
. $windowsPath

# Check if PowerShell-YAML module is installed
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Host "Installing PowerShell-YAML module..." -ForegroundColor Cyan
    Install-Module -Name powershell-yaml -Scope CurrentUser -Force
}

# Import the module
Import-Module powershell-yaml

# Create default user-config.yaml if it doesn't exist
$configPath = "$baseDir\user-config.yaml"
if (-not (Test-Path $configPath)) {
    $defaultConfig = @{
        colorScheme = "Perfect16"
        font = @{
            family = "SauceCodePro Nerd Font"
            size = 12
        }
        terminal = @{
            scrollback = 10000
        }
    }
    
    # Convert to YAML and save
    $yamlContent = ConvertTo-Yaml $defaultConfig
    $yamlContent = "# Global user configuration`n" + $yamlContent
    Set-Content -Path $configPath -Value $yamlContent
    
    Write-Host "Created default user configuration at $configPath" -ForegroundColor Green
}

# Install core components
Write-Host "Installing core components..." -ForegroundColor Cyan

# Download core files if running remotely
if ($isRemote) {
    New-Item -ItemType Directory -Path "$baseDir\core\profiles" -Force | Out-Null
    New-Item -ItemType Directory -Path "$baseDir\core\terminal" -Force | Out-Null
    New-Item -ItemType Directory -Path "$baseDir\core\colors" -Force | Out-Null
    
    Get-RemoteFile -RelativePath "core/profiles/powershell.ps1" -OutputPath "$baseDir\core\profiles\powershell.ps1"
    Get-RemoteFile -RelativePath "core/terminal/windows.json" -OutputPath "$baseDir\core\terminal\windows.json"
    Get-RemoteFile -RelativePath "core/colors/perfect16.yaml" -OutputPath "$baseDir\core\colors\perfect16.yaml"
}

# Install shell profile
$profileDir = Split-Path $PROFILE
$profilePath = $PROFILE

# Create profile directory if it doesn't exist
if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}

# Read profile template
$profileTemplate = Get-Content "$baseDir\core\profiles\powershell.ps1" -Raw -ErrorAction SilentlyContinue
if ($profileTemplate) {
    # Write to profile
    Set-Content -Path $profilePath -Value $profileTemplate
    Write-Host "PowerShell profile installed to $profilePath" -ForegroundColor Green
} else {
    Write-Host "PowerShell profile template not found" -ForegroundColor Red
}

# Install terminal config
Write-Host "Installing Windows Terminal configuration..." -ForegroundColor Cyan
$wtConfigPath = "$baseDir\core\terminal\windows.json"
if (Test-Path $wtConfigPath) {
    $wtSettings = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $wtPreviewSettings = "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    
    $settingsPath = ""
    if (Test-Path $wtSettings) {
        $settingsPath = $wtSettings
    } elseif (Test-Path $wtPreviewSettings) {
        $settingsPath = $wtPreviewSettings
    }
    
    if ($settingsPath) {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
        $colorScheme = Get-Content $wtConfigPath -Raw | ConvertFrom-Json
        
        # Check if the schemes array exists, if not, create it
        if (-not $settings.schemes) {
            $settings | Add-Member -Type NoteProperty -Name schemes -Value @()
        }
        
        # Remove existing scheme with the same name if it exists
        $settings.schemes = $settings.schemes | Where-Object { $_.name -ne $colorScheme.name }
        
        # Add the new color scheme
        $settings.schemes += $colorScheme
        
        # Save the updated settings
        $settings | ConvertTo-Json -Depth 32 | Set-Content $settingsPath
        
        Write-Host "Windows Terminal color scheme installed successfully!" -ForegroundColor Green
    } else {
        Write-Host "Windows Terminal settings file not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "Windows Terminal configuration not found" -ForegroundColor Red
}

# Install fonts
Write-Host "Would you like to install the SauceCodePro Nerd Font? (y/n): " -NoNewline
$installFonts = Read-Host

if ($installFonts -eq "y") {
    Write-Host "Downloading SauceCodePro Nerd Font..." -ForegroundColor Cyan
    $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip"
    $fontZip = "$env:TEMP\SauceCodePro.zip"
    $fontDir = "$env:TEMP\SauceCodePro"
    
    # Download font
    Invoke-WebRequest -Uri $fontUrl -OutFile $fontZip
    
    # Extract font
    Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force
    
    # Install font
    $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
    Get-ChildItem -Path $fontDir -Filter "*.ttf" | ForEach-Object {
        Write-Host "Installing font: $($_.Name)" -ForegroundColor Cyan
        $fonts.CopyHere($_.FullName)
    }
    
    # Clean up
    Remove-Item -Path $fontZip -Force
    Remove-Item -Path $fontDir -Recurse -Force
    
    Write-Host "Fonts installed successfully!" -ForegroundColor Green
}

# Clean up if running remotely
if ($isRemote -and (Test-Path $baseDir)) {
    Remove-Item -Path $baseDir -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Installation complete!" -ForegroundColor Green