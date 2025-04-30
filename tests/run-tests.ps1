# Test runner for Windows systems

function Run-ColorTest {
    & "$PSScriptRoot\common\colortest.ps1"
}

function Run-UnicodeTest {
    # For now, we'll use the bash script with PowerShell
    # Later we'll create a proper PowerShell version
    Write-Host "Unicode test not yet implemented for PowerShell"
}

function Run-AsciiArt {
    Get-ChildItem "$PSScriptRoot\common\ascii\*.ascii" | ForEach-Object {
        Get-Content $_.FullName
        Write-Host
    }
}

# Main menu
while ($true) {
    Clear-Host
    Write-Host "Available tests:"
    Write-Host "1. Color test - Shows all terminal colors"
    Write-Host "2. Unicode test - Tests Unicode character support"
    Write-Host "3. ASCII art - Displays ASCII art"
    Write-Host "q. Exit"
    Write-Host
    $testChoice = Read-Host "Enter test number to run"

    switch ($testChoice) {
        "1" {
            Run-ColorTest
            Write-Host "`nPress any key to return to menu..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "2" {
            Run-UnicodeTest
            Write-Host "`nPress any key to return to menu..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "3" {
            Run-AsciiArt
            Write-Host "`nPress any key to return to menu..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "q" { exit 0 }
        default {
            Write-Host "Invalid choice."
            Start-Sleep -Seconds 2
        }
    }
}