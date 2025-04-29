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
    
    # Create a backup of the PuTTY registry settings
    $backupDir = Join-Path $env:USERPROFILE "PerfectPutty_Backups"
    if (-not (Test-Path $backupDir)) {
      New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupFile = Join-Path $backupDir "PuTTY_Registry_Backup_$timestamp.reg"
    
    Write-Host "Creating backup of PuTTY registry settings to $backupFile..." -ForegroundColor Cyan
    
    # Determine which registry keys are being modified by reading the .reg file
    $regContent = Get-Content $regFilePath -Raw
    $regKeyPattern = '^\[HKEY_[^\]]+\]'
    $regKeys = [regex]::Matches($regContent, $regKeyPattern) | ForEach-Object { $_.Value.Trim('[]') }
    
    # Export each registry key to the backup file
    foreach ($key in $regKeys) {
      if ($key -match "^HKEY_CURRENT_USER\\(.*)$") {
        $relativePath = $matches[1]
        Write-Host "Backing up registry key: $key" -ForegroundColor Gray
        
        # Export the registry key if it exists
        if (Test-Path "Registry::$key") {
          reg export "$key" "$backupFile.temp" /y | Out-Null
          
          # Append to the backup file if it exists, otherwise create it
          if (Test-Path $backupFile) {
            $tempContent = Get-Content "$backupFile.temp" -Raw
            # Skip the first two lines (Windows Registry Editor header) if not the first key
            $tempContent = $tempContent -replace "^Windows Registry Editor.*\r\n\r\n", ""
            Add-Content -Path $backupFile -Value $tempContent
          } else {
            Copy-Item "$backupFile.temp" $backupFile
          }
          
          # Clean up temp file
          Remove-Item "$backupFile.temp" -Force -ErrorAction SilentlyContinue
        }
      }
    }
    
    Write-Host "Registry backup created successfully!" -ForegroundColor Green
    
    # Apply the new settings
    try {
      Start-Process -FilePath "regedit.exe" -ArgumentList "/s `"$regFilePath`"" -Wait
      Write-Host "PuTTY registry settings applied successfully!" -ForegroundColor Green
    } catch {
      Write-Host "Error applying PuTTY registry settings: $_" -ForegroundColor Red
      
      $restore = Read-Host "Would you like to restore from backup? (y/n)"
      if ($restore -eq "y") {
        Write-Host "Restoring registry settings from $backupFile..." -ForegroundColor Yellow
        Start-Process -FilePath "regedit.exe" -ArgumentList "/s `"$backupFile`"" -Wait
        Write-Host "Registry settings restored successfully!" -ForegroundColor Green
      }
    }
  } else {
    Write-Host "PuTTY registry settings file not found at $regFilePath" -ForegroundColor Red
  }
}

# Call the installation function
Install-PuTTY