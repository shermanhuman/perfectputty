# Node.js add-on installation script for Windows

function Install-NodeJS {
  Write-Host "Installing Node.js with fnm (Fast Node Manager)..." -ForegroundColor Cyan
  
  # Check if fnm is already installed
  if (Get-Command fnm -ErrorAction SilentlyContinue) {
    Write-Host "fnm is already installed" -ForegroundColor Yellow
  } else {
    # Install fnm using PowerShell
    Write-Host "Installing fnm..." -ForegroundColor Cyan
    
    # Create .fnm directory
    $fnmDir = "$env:USERPROFILE\.fnm"
    if (-not (Test-Path $fnmDir)) {
      New-Item -Path $fnmDir -ItemType Directory -Force | Out-Null
    }
    
    # Download and install fnm
    $fnmUrl = "https://github.com/Schniz/fnm/releases/latest/download/fnm-windows.zip"
    $fnmZip = "$env:TEMP\fnm.zip"
    $fnmExe = "$fnmDir\fnm.exe"
    
    Invoke-WebRequest -Uri $fnmUrl -OutFile $fnmZip
    Expand-Archive -Path $fnmZip -DestinationPath $fnmDir -Force
    
    # Add fnm to PATH
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$fnmDir*") {
      [Environment]::SetEnvironmentVariable("Path", "$currentPath;$fnmDir", "User")
      $env:Path = "$env:Path;$fnmDir"
    }
    
    # Clean up
    Remove-Item -Path $fnmZip -Force
  }
  
  # Add fnm initialization to PowerShell profile
  $profileContent = @"
# fnm Node.js initialization
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    Write-Host "... " -ForegroundColor Magenta -NoNewline
    fnm env --use-on-cd | Out-String | Invoke-Expression
    `$nodeVersion = (node --version) -replace "v", ""
    Write-Host "fnm loaded: Node `$nodeVersion" -ForegroundColor Magenta
}
"@
  
  # Check if the profile already contains fnm initialization
  $currentProfile = Get-Content -Path $PROFILE -ErrorAction SilentlyContinue
  if ($currentProfile -notlike "*fnm Node.js initialization*") {
    Add-Content -Path $PROFILE -Value $profileContent
  }
  
  # Install latest Node.js version
  Write-Host "Installing latest Node.js version..." -ForegroundColor Cyan
  fnm install --latest
  fnm default latest
  
  Write-Host "Node.js installed successfully!" -ForegroundColor Green
}

# Call the installation function
Install-NodeJS