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

# Check if PowerShell-YAML module is installed
if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
    Write-Host "Installing PowerShell-YAML module..." -ForegroundColor Cyan
    Install-Module -Name powershell-yaml -Scope CurrentUser -Force
}

# Import the module
Import-Module powershell-yaml

# Create default user-config.yaml
$configPath = "$env:TEMP\user-config.yaml"
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

# Install core components
Write-Host "Installing core components..." -ForegroundColor Cyan

# PowerShell profile content
$profileContent = @"
# Miniconda initialization
`$condaPath = "C:\ProgramData\anaconda3\Scripts\conda.exe"
if (Test-Path `$condaPath) {
    Write-Host "... " -ForegroundColor Green -NoNewline
    & `$condaPath "shell.powershell" "hook" | Out-Null
    `$pythonVersion = (python --version) -replace "Python ", ""
    Write-Host "Miniconda loaded: Python `$pythonVersion" -ForegroundColor Green
}

# FNM Node.js initialization
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    Write-Host "... " -ForegroundColor Magenta -NoNewline
    fnm env --use-on-cd | Out-String | Invoke-Expression
    `$nodeVersion = (node --version) -replace "v", ""
    Write-Host "fnm loaded: Node `$nodeVersion" -ForegroundColor Magenta
}

# Command Line Colors and Git Support
if (-not (Get-Module -ListAvailable -Name posh-git)) {
    Install-Module posh-git -Scope CurrentUser -Force
}
Import-Module posh-git

function prompt {
    `$origLastExitCode = `$LASTEXITCODE
    
    # ANSI color codes
    `$colors = @{
        PaleYellow = "`e[38;5;223m"
        PaleHotPink = "`e[38;5;218m"
        PaleBrightGreen = "`e[38;5;156m"
        VeryPaleGreen = "`e[38;5;194m"  # New color: even paler and whiter green
        PalePurple = "`e[38;5;183m"
        Reset = "`e[0m"
        Bold = "`e[1m"
    }
    
    # Get current path
    `$curPath = `$ExecutionContext.SessionState.Path.CurrentLocation.Path
    if (`$curPath.ToLower().StartsWith(`$Home.ToLower())) {
        `$curPath = "~" + `$curPath.SubString(`$Home.Length)
    }
    
    # Get Git information
    `$gitStatus = Get-GitStatus
    `$gitInfo = ""
    if (`$gitStatus) {
        `$branchName = `$gitStatus.Branch
        `$gitInfo = " `$(`$colors.PalePurple)git:(`$(`$colors.PaleYellow)`$branchName`$(`$colors.PalePurple))"
        if (`$gitStatus.Working.Count -gt 0) { `$gitInfo += "+`$(`$gitStatus.Working.Count)" }
        if (`$gitStatus.Untracked.Count -gt 0) { `$gitInfo += "?" }
        if (`$gitStatus.AheadBy -gt 0) { `$gitInfo += "↑`$(`$gitStatus.AheadBy)" }
        if (`$gitStatus.BehindBy -gt 0) { `$gitInfo += "↓`$(`$gitStatus.BehindBy)" }
        `$gitInfo += `$colors.Reset
    }
    
    # Check if running as admin
    `$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    `$promptEmoji = if (`$isAdmin) { "🔥" } else { "✨" }
    
    # Build the prompt
    `$hostname = [System.Net.Dns]::GetHostName()
    `$promptString = @(
        "`$promptEmoji `$(`$colors.Bold)`$(`$colors.PaleYellow)`$hostname`$(`$colors.Reset)"
        "`$(`$colors.Bold)`$(`$colors.PaleHotPink)`$curPath`$(`$colors.Reset)"
    )
    
    # Add Conda environment information
    if (`$env:CONDA_DEFAULT_ENV -and `$env:CONDA_DEFAULT_ENV -ne "base") {
        `$promptString += "`$(`$colors.VeryPaleGreen)🐍`$(`$colors.PaleBrightGreen):[`$(`$colors.VeryPaleGreen)`$env:CONDA_DEFAULT_ENV`$(`$colors.PaleBrightGreen)]`$(`$colors.Reset)"
    }
    
    # Add Git information
    if (`$gitStatus) {
        `$promptString += `$gitInfo
    }
    
    # Output the prompt
    Write-Host (`$promptString -join " ")
    
    `$LASTEXITCODE = `$origLastExitCode
    return "`$(`$colors.Bold)❯`$(`$colors.Reset) "
}
"@

# Install PowerShell profile
$profileDir = Split-Path $PROFILE
$profilePath = $PROFILE

# Create profile directory if it doesn't exist
if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}

# Write profile
Set-Content -Path $profilePath -Value $profileContent
Write-Host "PowerShell profile installed to $profilePath" -ForegroundColor Green

# Windows Terminal color scheme
$colorScheme = @{
    name = "Perfect"
    background = "#0F1011"
    foreground = "#C3C3C3"
    cursorColor = "#D5DDd2"
    selectionBackground = "#121212"
    black = "#444448"
    blue = "#66728e"
    cyan = "#6F99A6"
    green = "#799D6A"
    purple = "#AF87AE"
    red = "#B94D35"
    white = "#DDDDDD"
    yellow = "#FFB964"
    brightBlack = "#554F4F"
    brightBlue = "#82A3BF"
    brightCyan = "#91CADB"
    brightGreen = "#7CB165"
    brightPurple = "#EABBe9"
    brightRed = "#D65F45"
    brightWhite = "#EFEFE0"
    brightYellow = "#FAD07A"
}

# Install Windows Terminal color scheme
Write-Host "Installing Windows Terminal configuration..." -ForegroundColor Cyan
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

Write-Host "Installation complete!" -ForegroundColor Green