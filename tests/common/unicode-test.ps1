# PowerShell Unicode and Nerd Font Test

# ANSI escape sequence helper
$ESC = [char]27

function Write-ColoredText {
    param (
        [string]$Text,
        [string]$ForegroundColor = "",
        [string]$BackgroundColor = "",
        [switch]$Bold,
        [switch]$Underline
    )
    
    $format = ""
    if ($Bold) { $format += "${ESC}[1m" }
    if ($Underline) { $format += "${ESC}[4m" }
    if ($ForegroundColor) { $format += $ForegroundColor }
    if ($BackgroundColor) { $format += $BackgroundColor }
    
    Write-Host -NoNewline "$format$Text${ESC}[0m"
}

# Title
Write-Host "`n`n" -NoNewline
Write-ColoredText "╔══════════════════════════════════════════════════════════════════════════════╗`n" -ForegroundColor "${ESC}[36m" -Bold
Write-ColoredText "║                      " -ForegroundColor "${ESC}[36m" -Bold
Write-ColoredText "UNICODE AND NERD FONT TEST" -ForegroundColor "${ESC}[33m" -Bold
Write-ColoredText "                       ║`n" -ForegroundColor "${ESC}[36m" -Bold
Write-ColoredText "╚══════════════════════════════════════════════════════════════════════════════╝`n`n" -ForegroundColor "${ESC}[36m" -Bold

# Unicode Characters Section
Write-ColoredText "UNICODE CHARACTERS" -ForegroundColor "${ESC}[35m" -Bold
Write-Host "`n"
Write-Host "Basic Unicode Symbols:"
Write-Host "█ ▓ ▒ ░ ▄ ▀ ▐ ▌ ● ═ ║ ╔ ╦ ╗ ╚ ╩ ╝ ■ ▬ ▲ ▼ ◄ ► ┌┼└┼└ ┐┌ ─ ┤├"
Write-Host

Write-Host "Box Drawing Characters:"
Write-Host "┌─────────────────────────────────────────────────────────────┐"
Write-Host "│ ┌───┬───┐ ┌───┬───┐ ┌───┬───┐ ┌───┬───┐ ┌───┬───┐ ┌───┬───┐ │"
Write-Host "│ │   │   │ │   │   │ │   │   │ │   │   │ │   │   │ │   │   │ │"
Write-Host "│ ├───┼───┤ ├───┼───┤ ├───┼───┤ ├───┼───┤ ├───┼───┤ ├───┼───┤ │"
Write-Host "│ │   │   │ │   │   │ │   │   │ │   │   │ │   │   │ │   │   │ │"
Write-Host "│ └───┴───┘ └───┴───┘ └───┴───┘ └───┴───┘ └───┴───┘ └───┴───┘ │"
Write-Host "└─────────────────────────────────────────────────────────────┘"
Write-Host

# Nerd Font Icons Section
Write-ColoredText "NERD FONT ICONS" -ForegroundColor "${ESC}[35m" -Bold
Write-Host "`n"
Write-Host "If your Nerd Font is properly installed, you should see icons below:"
Write-Host

Write-Host "Development Icons:"
Write-Host "  Git:             "
Write-Host "  GitHub:          "
Write-Host "  GitLab:          "
Write-Host "  Python:          "
Write-Host "  JavaScript:      "
Write-Host "  Node.js:         "
Write-Host "  Docker:          "
Write-Host "  Visual Studio:   "
Write-Host "  VS Code:         "
Write-Host

Write-Host "Operating System Icons:"
Write-Host "  Windows:         "
Write-Host "  Linux:           "
Write-Host "  Apple:           "
Write-Host "  Android:         "
Write-Host

Write-Host "Other Icons:"
Write-Host "  Home:            "
Write-Host "  Folder:          "
Write-Host "  File:            "
Write-Host "  Terminal:        "
Write-Host "  Search:          "
Write-Host "  Settings:        "
Write-Host "  Warning:         "
Write-Host "  Error:           "
Write-Host "  Info:            "
Write-Host "  Success:         "
Write-Host

# ANSI Color Chart
Write-ColoredText "ANSI COLOR CHART" -ForegroundColor "${ESC}[35m" -Bold
Write-Host "`n"

Write-Host "╔═══════════════════════════════════════════════════════╗"
Write-Host "║                 CONSOLE COLOR CHART                   ║"
Write-Host "║                                                       ║"
Write-Host "║  COLOR    TEXT BACKGROUND  COLOR          TEXT        ║"

# Standard colors
Write-Host -NoNewline "║  "
Write-Host -NoNewline "${ESC}[30mBlack      30${ESC}[0m     40      "
Write-Host -NoNewline "${ESC}[1;30mDark Gray      1;30${ESC}[0m"
Write-Host "    ║"

Write-Host -NoNewline "║  "
Write-Host -NoNewline "${ESC}[31mRed        31${ESC}[0m     41      "
Write-Host -NoNewline "${ESC}[1;31mLight Red      1;31${ESC}[0m"
Write-Host "    ║"

Write-Host -NoNewline "║  "
Write-Host -NoNewline "${ESC}[32mGreen      32${ESC}[0m     42      "
Write-Host -NoNewline "${ESC}[1;32mLight Green    1;32${ESC}[0m"
Write-Host "    ║"

Write-Host -NoNewline "║  "
Write-Host -NoNewline "${ESC}[33mYellow     33${ESC}[0m     43      "
Write-Host -NoNewline "${ESC}[1;33mLight Yellow   1;33${ESC}[0m"
Write-Host "    ║"

Write-Host -NoNewline "║  "
Write-Host -NoNewline "${ESC}[34mBlue       34${ESC}[0m     44      "
Write-Host -NoNewline "${ESC}[1;34mLight Blue     1;34${ESC}[0m"
Write-Host "    ║"

Write-Host -NoNewline "║  "
Write-Host -NoNewline "${ESC}[35mMagenta    35${ESC}[0m     45      "
Write-Host -NoNewline "${ESC}[1;35mLight Magenta  1;35${ESC}[0m"
Write-Host "    ║"

Write-Host -NoNewline "║  "
Write-Host -NoNewline "${ESC}[36mCyan       36${ESC}[0m     46      "
Write-Host -NoNewline "${ESC}[1;36mLight Cyan     1;36${ESC}[0m"
Write-Host "    ║"

Write-Host -NoNewline "║  "
Write-Host -NoNewline "${ESC}[37mLight Gray 37${ESC}[0m     47      "
Write-Host -NoNewline "${ESC}[1;37mWhite          1;37${ESC}[0m"
Write-Host "    ║"

Write-Host "║                                                       ║"
Write-Host "║  FORMAT         FORMAT                                ║"
Write-Host "║  reset          0            underscore on,           ║"
Write-Host "║  ${ESC}[1mbold           1${ESC}[0m  default foreground color 38        ║"
Write-Host "║  half-bright    2           underscore off,           ║"
Write-Host "║  ${ESC}[4munderline${ESC}[0m      ${ESC}[4m4${ESC}[0m  default foreground color 39        ║"
Write-Host "║  blink          5  default background color 49        ║"
Write-Host "║  inverse        7                                     ║"
Write-Host "║  conceal        8                                     ║"
Write-Host "║  normal        22                                     ║"
Write-Host "║  underline off 24                                     ║"
Write-Host "║  blink off     25                                     ║"
Write-Host "║  inverse off   27                                     ║"
Write-Host "║                                                       ║"
Write-Host "╚═══════════════════════════════════════════════════════╝"
Write-Host