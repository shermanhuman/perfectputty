# Miniconda initialization
$condaPath = "$env:USERPROFILE\miniconda3\Scripts\conda.exe"
if (Test-Path $condaPath) {
    (& $condaPath "shell.powershell" "hook") | Out-String | Invoke-Expression
}

# FNM Node.js initialization
if (Get-Command fnm -ErrorAction SilentlyContinue) {
    fnm env --use-on-cd | Out-String | Invoke-Expression
    fnm use default
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
        $gitInfo = " $($colors.PalePurple)git:($($colors.PaleYellow)$branchName$($colors.PalePurple))"
        if ($gitStatus.Working.Count -gt 0) { $gitInfo += "+$($gitStatus.Working.Count)" }
        if ($gitStatus.Untracked.Count -gt 0) { $gitInfo += "?" }
        if ($gitStatus.AheadBy -gt 0) { $gitInfo += "↑$($gitStatus.AheadBy)" }
        if ($gitStatus.BehindBy -gt 0) { $gitInfo += "↓$($gitStatus.BehindBy)" }
        $gitInfo += $colors.Reset
    }
    
    # Build the prompt
    $hostname = [System.Net.Dns]::GetHostName()
    $promptString = @(
        "✨ $($colors.Bold)$($colors.PaleYellow)$hostname$($colors.Reset)"
        "$($colors.Bold)$($colors.PaleHotPink)$curPath$($colors.Reset)"
    )
    
    # Add Conda environment information
    if ($env:CONDA_DEFAULT_ENV -and $env:CONDA_DEFAULT_ENV -ne "base") {
        $promptString += "$($colors.VeryPaleGreen)🐍$($colors.PaleBrightGreen):[$($colors.VeryPaleGreen)$env:CONDA_DEFAULT_ENV$($colors.PaleBrightGreen)]$($colors.Reset)"
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