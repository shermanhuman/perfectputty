# Python environment detection
function Get-PythonEnvironment {
    # Check for active virtual environment
    if ($env:VIRTUAL_ENV) {
        return @{
            Type = "venv"
            Path = $env:VIRTUAL_ENV
            Version = (python --version 2>$null) -replace "Python ", ""
        }
    }
    
    # Check for .venv directory in current or parent directories
    $currentDir = Get-Location
    $venvPath = Join-Path $currentDir ".venv"
    if (Test-Path $venvPath) {
        $venvPython = Join-Path $venvPath "Scripts\python.exe"
        if (Test-Path $venvPython) {
            $version = & $venvPython --version 2>$null
            $version = $version -replace "Python ", ""
            return @{
                Type = "venv"
                Path = $venvPath
                Version = $version
            }
        }
    }
    
    # Check for .python-version file (used by uv and other tools)
    $pythonVersionFile = Join-Path $currentDir ".python-version"
    if (Test-Path $pythonVersionFile) {
        $requestedVersion = Get-Content $pythonVersionFile -Raw
        $pythonVersion = (python --version 2>$null) -replace "Python ", ""
        return @{
            Type = "pinned"
            Version = $pythonVersion
            Requested = $requestedVersion.Trim()
        }
    }
    
    # Default system Python
    $pythonVersion = (python --version 2>$null) -replace "Python ", ""
    if ($pythonVersion) {
        return @{
            Type = "system"
            Version = $pythonVersion
        }
    }
    
    return $null
}

# Initialize Python environment
$pythonEnv = Get-PythonEnvironment
if ($pythonEnv) {
    Write-Host "`u{e73c} " -ForegroundColor Green -NoNewline
    if ($pythonEnv.Type -eq "venv") {
        Write-Host "Python $($pythonEnv.Version) (venv)" -ForegroundColor Green
    } elseif ($pythonEnv.Type -eq "pinned") {
        Write-Host "Python $($pythonEnv.Version) (pinned: $($pythonEnv.Requested))" -ForegroundColor Green
    } else {
        Write-Host "Python $($pythonEnv.Version)" -ForegroundColor Green
    }
}

# FNM Node.js initialization
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    Write-Host "`u{e719} " -ForegroundColor Magenta -NoNewline
    
    # Enable automatic version switching when entering directories
    fnm env --use-on-cd | Out-String | Invoke-Expression
    
    # Check for .node-version or .nvmrc file in current directory
    $nodeVersionFile = if (Test-Path ".node-version") { ".node-version" } elseif (Test-Path ".nvmrc") { ".nvmrc" } else { $null }
    
    if ($nodeVersionFile) {
        $requestedVersion = Get-Content $nodeVersionFile -Raw
        fnm use $requestedVersion.Trim() 2>&1 | Out-Null
    }
    
    $nodeVersion = (node --version 2>$null) -replace "v", ""
    Write-Host "Node $nodeVersion" -ForegroundColor Magenta
}

# Command Line Colors and Git Support
if (-not (Get-Module -ListAvailable -Name posh-git)) {
    Install-Module posh-git -Scope CurrentUser -Force
}
Import-Module posh-git

function prompt {
    $origLastExitCode = $LASTEXITCODE
    
    # ANSI color codes
    $colors = @{
        PaleYellow = "`e[38;5;223m"
        PaleHotPink = "`e[38;5;218m"
        PaleBrightGreen = "`e[38;5;156m"
        VeryPaleGreen = "`e[38;5;194m"  # New color: even paler and whiter green
        PalePurple = "`e[38;5;183m"
        Reset = "`e[0m"
        Bold = "`e[1m"
    }
    
    # Get current path
    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curPath.ToLower().StartsWith($Home.ToLower())) {
        $curPath = "~" + $curPath.SubString($Home.Length)
    }
    
    # Get Git information
    $gitStatus = Get-GitStatus
    $gitInfo = ""
    if ($gitStatus) {
        $branchName = $gitStatus.Branch
        $gitInfo = " $($colors.PalePurple)`u{eafc} ($($colors.PaleYellow)$branchName$($colors.PalePurple))"
        if ($gitStatus.Working.Count -gt 0) { $gitInfo += "+$($gitStatus.Working.Count)" }
        if ($gitStatus.Untracked.Count -gt 0) { $gitInfo += "?" }
        if ($gitStatus.AheadBy -gt 0) { $gitInfo += "↑$($gitStatus.AheadBy)" }
        if ($gitStatus.BehindBy -gt 0) { $gitInfo += "↓$($gitStatus.BehindBy)" }
        $gitInfo += $colors.Reset
    }
    
    # Check if running as admin
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $promptEmoji = if ($isAdmin) { "🔥" } else { "✨" }
    
    # Build the prompt
    $hostname = [System.Net.Dns]::GetHostName()
    $promptString = @(
        "$promptEmoji $($colors.Bold)$($colors.PaleYellow)$hostname$($colors.Reset)"
        "$($colors.Bold)$($colors.PaleHotPink)$curPath$($colors.Reset)"
    )
    
    # Add Python environment information
    $pythonEnv = Get-PythonEnvironment
    if ($pythonEnv) {
        if ($pythonEnv.Type -eq "venv") {
            $venvName = Split-Path -Leaf (Split-Path -Parent $pythonEnv.Path)
            if ($venvName -eq ".venv") {
                $venvName = Split-Path -Leaf (Get-Location)
            }
            $promptString += "$($colors.VeryPaleGreen)`u{e73c}$($colors.PaleBrightGreen):[$($colors.VeryPaleGreen)$venvName$($colors.PaleBrightGreen)]$($colors.Reset)"
        } elseif ($pythonEnv.Type -eq "pinned") {
            $promptString += "$($colors.VeryPaleGreen)`u{e73c}$($colors.PaleBrightGreen):[$($colors.VeryPaleGreen)$($pythonEnv.Version)$($colors.PaleBrightGreen)]$($colors.Reset)"
        }
    }
    
    # Add Node.js environment information
    if (Get-Command fnm -ErrorAction SilentlyContinue) {
        $nodeVersion = (node --version 2>$null) -replace "v", ""
        if ($nodeVersion) {
            $promptString += "$($colors.PalePurple)`u{e719}$($colors.PaleBrightGreen):[$($colors.PalePurple)$nodeVersion$($colors.PaleBrightGreen)]$($colors.Reset)"
        }
    }
    
    # Add Git information
    if ($gitStatus) {
        $promptString += $gitInfo
    }
    
    # Output the prompt
    Write-Host ($promptString -join " ")
    
    $LASTEXITCODE = $origLastExitCode
    return "$($colors.Bold)❯$($colors.Reset) "
}