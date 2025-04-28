# Miniconda add-on installation script for Windows

function Install-Miniconda {
  param (
    [string]$InstallDir = "$env:USERPROFILE\miniconda3"
  )
  
  Write-Host "Installing Miniconda..." -ForegroundColor Cyan
  
  # Check if already installed
  if (Test-Path "$InstallDir\Scripts\conda.exe") {
    Write-Host "Miniconda already installed at $InstallDir" -ForegroundColor Yellow
    return
  }
  
  # Download and install Miniconda
  $installerUrl = "https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe"
  $installerPath = "$env:TEMP\miniconda_installer.exe"
  
  Write-Host "Downloading Miniconda installer..." -ForegroundColor Cyan
  Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath
  
  Write-Host "Installing Miniconda to $InstallDir..." -ForegroundColor Cyan
  Start-Process -FilePath $installerPath -ArgumentList "/S /D=$InstallDir" -Wait
  
  # Add to PowerShell profile
  $profileContent = @"
# Miniconda initialization
`$condaPath = "$InstallDir\Scripts\conda.exe"
if (Test-Path `$condaPath) {
    Write-Host "... " -ForegroundColor Green -NoNewline
    & `$condaPath "shell.powershell" "hook" | Out-String | Invoke-Expression
    `$pythonVersion = (python --version) -replace "Python ", ""
    Write-Host "Miniconda loaded: Python `$pythonVersion" -ForegroundColor Green
}
"@
  
  Add-Content -Path $PROFILE -Value $profileContent
  
  # Clean up
  Remove-Item -Path $installerPath -Force
  
  Write-Host "Miniconda installed successfully!" -ForegroundColor Green
}

# Call the installation function
Install-Miniconda