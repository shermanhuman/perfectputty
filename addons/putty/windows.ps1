# PuTTY add-on installation script for Windows

function Install-PuTTY {
  Write-Host "Installing PuTTY configuration..." -ForegroundColor Cyan
  
  # Check if PuTTY is installed
  $puttyPath = "C:\Program Files\PuTTY\putty.exe"
  if (-not (Test-Path $puttyPath)) {
    $puttyPath = "C:\Program Files (x86)\PuTTY\putty.exe"
    if (-not (Test-Path $puttyPath)) {
      Write-Host "PuTTY not found. Would you like to download and install it? (y/n): " -NoNewline -ForegroundColor Yellow
      $installPuTTY = Read-Host
      
      if ($installPuTTY -eq "y") {
        # Download and install PuTTY
        $puttyUrl = "https://the.earth.li/~sgtatham/putty/latest/w64/putty-64bit-0.80-installer.msi"
        $puttyInstaller = Join-Path $env:TEMP "putty-installer.msi"
        
        Write-Host "Downloading PuTTY installer..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $puttyUrl -OutFile $puttyInstaller
        
        Write-Host "Installing PuTTY..." -ForegroundColor Cyan
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$puttyInstaller`" /quiet" -Wait
        
        # Clean up
        Remove-Item -Path $puttyInstaller -Force
      } else {
        Write-Host "PuTTY installation skipped. Registry settings will still be applied." -ForegroundColor Yellow
      }
    }
  }
  
  # Apply registry settings
  $regFilePath = Join-Path $PSScriptRoot "..\..\default-settings.reg"
  if (Test-Path $regFilePath) {
    Write-Host "Applying PuTTY registry settings..." -ForegroundColor Cyan
    Start-Process -FilePath "regedit.exe" -ArgumentList "/s `"$regFilePath`"" -Wait
    Write-Host "PuTTY registry settings applied successfully!" -ForegroundColor Green
  } else {
    Write-Host "PuTTY registry settings file not found at $regFilePath" -ForegroundColor Red
  }
}

# Call the installation function
Install-PuTTY