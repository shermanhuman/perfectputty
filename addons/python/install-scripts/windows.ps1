# Python add-on installation script for Windows

function Install-Python {
  Write-Host "Installing Python with uv (Astral Package Manager)..." -ForegroundColor Cyan
  
  # Check if uv is already installed
  if (Get-Command uv -ErrorAction SilentlyContinue) {
    Write-Host "uv is already installed" -ForegroundColor Yellow
  } else {
    # Install uv using PowerShell
    Write-Host "Installing uv..." -ForegroundColor Cyan
    
    # Use the official installer
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    
    # Verify installation
    if (Get-Command uv -ErrorAction SilentlyContinue) {
      Write-Host "uv installed successfully!" -ForegroundColor Green
    } else {
      Write-Host "Failed to install uv. Please install it manually." -ForegroundColor Red
      return
    }
  }
  
  # Install Python using uv
  Write-Host "Installing latest Python version using uv..." -ForegroundColor Cyan
  uv python install
  
  # Add Python environment detection and initialization to PowerShell profile
  $profileContent = @"
# Python environment detection
function Get-PythonEnvironment {
    # Check for active virtual environment
    if (`$env:VIRTUAL_ENV) {
        return @{
            Type = "venv"
            Path = `$env:VIRTUAL_ENV
            Version = (python --version 2>`$null) -replace "Python ", ""
        }
    }
    
    # Check for .venv directory in current or parent directories
    `$currentDir = Get-Location
    `$venvPath = Join-Path `$currentDir ".venv"
    if (Test-Path `$venvPath) {
        `$venvPython = Join-Path `$venvPath "Scripts\python.exe"
        if (Test-Path `$venvPython) {
            `$version = & `$venvPython --version 2>`$null
            `$version = `$version -replace "Python ", ""
            return @{
                Type = "venv"
                Path = `$venvPath
                Version = `$version
            }
        }
    }
    
    # Check for .python-version file (used by uv and other tools)
    `$pythonVersionFile = Join-Path `$currentDir ".python-version"
    if (Test-Path `$pythonVersionFile) {
        `$requestedVersion = Get-Content `$pythonVersionFile -Raw
        `$pythonVersion = (python --version 2>`$null) -replace "Python ", ""
        return @{
            Type = "pinned"
            Version = `$pythonVersion
            Requested = `$requestedVersion.Trim()
        }
    }
    
    # Default system Python
    `$pythonVersion = (python --version 2>`$null) -replace "Python ", ""
    if (`$pythonVersion) {
        return @{
            Type = "system"
            Version = `$pythonVersion
        }
    }
    
    return `$null
}

# Initialize Python environment
`$pythonEnv = Get-PythonEnvironment
if (`$pythonEnv) {
    Write-Host "`u{e73c} " -ForegroundColor Green -NoNewline
    if (`$pythonEnv.Type -eq "venv") {
        Write-Host "Python `$(`$pythonEnv.Version) (venv)" -ForegroundColor Green
    } elseif (`$pythonEnv.Type -eq "pinned") {
        Write-Host "Python `$(`$pythonEnv.Version) (pinned: `$(`$pythonEnv.Requested))" -ForegroundColor Green
    } else {
        Write-Host "Python `$(`$pythonEnv.Version)" -ForegroundColor Green
    }
}

# Add Python environment information to the prompt
`$promptAddition = @'

# Add Python environment information to the prompt
function Add-PythonEnvironmentToPrompt {
    param (
        [Parameter(Mandatory=`$true)]
        [System.Collections.ArrayList]`$PromptString,
        
        [Parameter(Mandatory=`$true)]
        [hashtable]`$Colors
    )
    
    `$pythonEnv = Get-PythonEnvironment
    if (`$pythonEnv) {
        if (`$pythonEnv.Type -eq "venv") {
            `$venvName = Split-Path -Leaf (Split-Path -Parent `$pythonEnv.Path)
            if (`$venvName -eq ".venv") {
                `$venvName = Split-Path -Leaf (Get-Location)
            }
            `$PromptString += "`$(`$Colors.VeryPaleGreen)`u{e73c}`$(`$Colors.PaleBrightGreen):[`$(`$Colors.VeryPaleGreen)`$venvName`$(`$Colors.PaleBrightGreen)]`$(`$Colors.Reset)"
        } elseif (`$pythonEnv.Type -eq "pinned") {
            `$PromptString += "`$(`$Colors.VeryPaleGreen)`u{e73c}`$(`$Colors.PaleBrightGreen):[`$(`$Colors.VeryPaleGreen)`$(`$pythonEnv.Version)`$(`$Colors.PaleBrightGreen)]`$(`$Colors.Reset)"
        }
    }
    
    return `$PromptString
}

# Hook into the prompt function
`$oldPrompt = Get-Content function:prompt
`$newPrompt = `$oldPrompt.ToString() -replace '# Python environment information will be added by the Python add-on if installed', '`$promptString = Add-PythonEnvironmentToPrompt -PromptString `$promptString -Colors `$colors'
Set-Item -Path function:prompt -Value ([ScriptBlock]::Create(`$newPrompt))
'@

Add-Content -Path `$PROFILE -Value `$promptAddition
"@
  
  # Check if the profile already contains Python initialization
  $currentProfile = Get-Content -Path $PROFILE -ErrorAction SilentlyContinue
  if ($currentProfile -notlike "*Python environment detection*") {
    Add-Content -Path $PROFILE -Value $profileContent
  }
  
  Write-Host "Python installed successfully!" -ForegroundColor Green
}

# Call the installation function
Install-Python