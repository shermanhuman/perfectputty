############# Command Line Colors and Git Support ##########

# Install required modules if not already installed
if (-not (Get-Module -ListAvailable -Name posh-git)) {
    Install-Module posh-git -Scope CurrentUser -Force
}

Import-Module posh-git

function prompt {
    $origLastExitCode = $LASTEXITCODE
    
    # Get current path
    $curPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($curPath.ToLower().StartsWith($Home.ToLower())) {
        $curPath = "~" + $curPath.SubString($Home.Length)
    }

    # Get Git information
    $gitStatus = Get-GitStatus
    if ($gitStatus) {
        $branchName = $gitStatus.Branch
        $uncommittedChanges = $gitStatus.Working.Count
        $untrackedFiles = $gitStatus.Untracked.Count
        $aheadBy = $gitStatus.AheadBy
        $behindBy = $gitStatus.BehindBy

        $gitInfo = " git:($($branchName))"
        if ($uncommittedChanges -gt 0) { $gitInfo += "+$uncommittedChanges" }
        if ($untrackedFiles -gt 0) { $gitInfo += "?" }
        if ($aheadBy -gt 0) { $gitInfo += "↑$aheadBy" }
        if ($behindBy -gt 0) { $gitInfo += "↓$behindBy" }
    }

    # ANSI color codes
    $paleYellow = "`e[38;5;223m"
    $paleHotPink = "`e[38;5;218m"
    $paleBrightGreen = "`e[38;5;156m"
    $reset = "`e[0m"
    $bold = "`e[1m"

    # Build the prompt
    $hostname = [System.Net.Dns]::GetHostName()
    $promptString = "$paleYellow$hostname$reset $bold$paleHotPink$curPath$reset"
    if ($gitStatus) {
        $promptString += "$paleBrightGreen git:($paleYellow$branchName$paleBrightGreen)$reset"
        if ($uncommittedChanges -gt 0 -or $untrackedFiles -gt 0 -or $aheadBy -gt 0 -or $behindBy -gt 0) {
            $promptString += "$paleBrightGreen"
            if ($uncommittedChanges -gt 0) { $promptString += "+$uncommittedChanges" }
            if ($untrackedFiles -gt 0) { $promptString += "?" }
            if ($aheadBy -gt 0) { $promptString += "↑$aheadBy" }
            if ($behindBy -gt 0) { $promptString += "↓$behindBy" }
            $promptString += "$reset"
        }
    }
    $promptString += "`n❯ "

    # Output the prompt
    Write-Host $promptString -NoNewline
    
    $LASTEXITCODE = $origLastExitCode
    return " "
}

