# Windows-specific installation functions

function Install-ShellProfile {
  $profileDir = Split-Path $PROFILE
  $profilePath = $PROFILE
  
  # Create profile directory if it doesn't exist
  if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
  }
  
  # Read profile template
  $profileTemplate = Get-Content (Join-Path $PSScriptRoot ".." "core" "profiles" "powershell.ps1") -Raw
  
  # Write to profile
  Set-Content -Path $profilePath -Value $profileTemplate
  
  Write-Host "PowerShell profile installed to $profilePath" -ForegroundColor Green
}

function Install-TerminalConfig {
  Write-Host "Installing Windows Terminal configuration..." -ForegroundColor Cyan
  
  $wtScriptPath = Join-Path $PSScriptRoot ".." "win11" "Install-wt-color-scheme.ps1"
  if (Test-Path $wtScriptPath) {
    & $wtScriptPath
  } else {
    Write-Host "Windows Terminal installation script not found at $wtScriptPath" -ForegroundColor Yellow
  }
}

function Install-Fonts {
  Write-Host "Would you like to install the SauceCodePro Nerd Font? (y/n): " -NoNewline
  $installFonts = Read-Host
  
  if ($installFonts -ne "y") {
    return
  }
  
  Write-Host "Downloading SauceCodePro Nerd Font..." -ForegroundColor Cyan
  $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip"
  $fontZip = Join-Path $env:TEMP "SauceCodePro.zip"
  $fontDir = Join-Path $env:TEMP "SauceCodePro"
  
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