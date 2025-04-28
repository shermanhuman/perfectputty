# PowerShell Color Test Script

$ansi_mappings = @(
    "Black", "Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White",
    "Bright_Black", "Bright_Red", "Bright_Green", "Bright_Yellow",
    "Bright_Blue", "Bright_Magenta", "Bright_Cyan", "Bright_White"
)

$colors = @(
    "base00", "base08", "base0B", "base0A", "base0D", "base0E", "base0C", "base05",
    "base03", "base08", "base0B", "base0A", "base0D", "base0E", "base0C", "base07",
    "base09", "base0F", "base01", "base02", "base04", "base06"
)

Write-Host

for ($i = 0; $i -lt 16; $i++) {
    $padded_value = $i.ToString("00")
    $color_variable = "color$padded_value"
    $current_color = (Get-Variable -Name $color_variable -ErrorAction SilentlyContinue).Value
    $current_color = if ($current_color) { $current_color.ToUpper() } else { "... " }
    $base16_color_name = $colors[$i]
    $ansi_label = $ansi_mappings[$i]
    $block = "`e[48;5;${i}m                           `e[0m"  # Changed to spaces
    $foreground = "`e[38;5;${i}m$color_variable`e[0m"
    $output = "{0} {1} {2} {3,-30} {4}" -f $foreground, $base16_color_name, $current_color, $ansi_label, $block
    Write-Host $output
}

Write-Host

$T = 'perfect'
$FGs = @('    m', '   1m', '  30m', '1;30m', '  31m', '1;31m', '  32m',
         '1;32m', '  33m', '1;33m', '  34m', '1;34m', '  35m', '1;35m',
         '  36m', '1;36m', '  37m', '1;37m')

foreach ($FG in $FGs) {
    $FG = $FG.Trim()
    Write-Host -NoNewline " `e[${FG}  $T  `e[0m"
    foreach ($BG in 40..47) {
        Write-Host -NoNewline " `e[${FG}`e[${BG}m  $T  `e[0m"
    }
    Write-Host
}

Write-Host