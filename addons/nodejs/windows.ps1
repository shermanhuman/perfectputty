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
    Write-Host "`u{e719} " -ForegroundColor Magenta -NoNewline
    
    # Enable automatic version switching when entering directories
    fnm env --use-on-cd | Out-String | Invoke-Expression
    
    # Check for .node-version or .nvmrc file in current directory
    `$nodeVersionFile = if (Test-Path ".node-version") { ".node-version" } elseif (Test-Path ".nvmrc") { ".nvmrc" } else { `$null }
    
    if (`$nodeVersionFile) {
        `$requestedVersion = Get-Content `$nodeVersionFile -Raw
        fnm use `$requestedVersion.Trim() 2>&1 | Out-Null
    }
    
    `$nodeVersion = (node --version 2>`$null) -replace "v", ""
    Write-Host "Node `$nodeVersion" -ForegroundColor Magenta
}

# Add Node.js environment information to the prompt
function Add-NodeJsEnvironmentToPrompt {
    param (
        [Parameter(Mandatory=`$true)]
        [System.Collections.ArrayList]`$PromptString,
        
        [Parameter(Mandatory=`$true)]
        [hashtable]`$Colors
    )
    
    if (Get-Command fnm -ErrorAction SilentlyContinue) {
        `$nodeVersion = (node --version 2>`$null) -replace "v", ""
        if (`$nodeVersion) {
            `$PromptString += "`$(`$Colors.PalePurple)`u{e719}`$(`$Colors.PaleBrightGreen):[`$(`$Colors.PalePurple)`$nodeVersion`$(`$Colors.PaleBrightGreen)]`$(`$Colors.Reset)"
        }
    }
    
    return `$PromptString
}

# Hook into the prompt function
`$oldPrompt = Get-Content function:prompt
`$newPrompt = `$oldPrompt.ToString() -replace '# Node.js environment information will be added by the Node.js add-on if installed', '`$promptString = Add-NodeJsEnvironmentToPrompt -PromptString `$promptString -Colors `$colors'
Set-Item -Path function:prompt -Value ([ScriptBlock]::Create(`$newPrompt))
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