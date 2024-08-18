# Script to install custom color scheme for Windows Terminal

# Function to get Windows Terminal settings file path
function Get-WTSettingsPath {
    $settingsPath = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $settingsPath) {
        return $settingsPath
    }
    $settingsPath = "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $settingsPath) {
        return $settingsPath
    }
    throw "Windows Terminal settings file not found"
}

# Path to the color scheme JSON file
$colorSchemeFilePath = "WindowsTerminalColorScheme-Perfect.JSON"

# Read the color scheme from the JSON file
if (Test-Path $colorSchemeFilePath) {
    $colorScheme = Get-Content $colorSchemeFilePath | ConvertFrom-Json
} else {
    throw "Color scheme file not found: $colorSchemeFilePath"
}

# Get the settings file path
$settingsPath = Get-WTSettingsPath

# Read the current settings
$settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

# Check if the schemes array exists, if not, create it
if (-not $settings.schemes) {
    $settings | Add-Member -Type NoteProperty -Name schemes -Value @()
}

# Remove existing scheme with the same name if it exists
$settings.schemes = $settings.schemes | Where-Object { $_.name -ne $colorScheme.name }

# Add the new color scheme
$settings.schemes += $colorScheme

# Function to apply color scheme to a profile
function Set-ProfileColorScheme {
    param (
        [Parameter(Mandatory=$true)]
        [int]$profileIndex
    )
    $profile = $settings.profiles.list[$profileIndex]
    if ($profile.PSObject.Properties.Name -contains "colorScheme") {
        $profile.colorScheme = $colorScheme.name
    } else {
        $profile | Add-Member -Type NoteProperty -Name colorScheme -Value $colorScheme.name
    }
    Write-Host "Color scheme 'Perfect' has been set for profile: $($profile.name)"
}

# Ask if the user wants to set this as default for profiles
$setDefault = Read-Host "Do you want to set the 'Perfect' color scheme as default for profiles? (Y/N)"

if ($setDefault -eq 'Y') {
    while ($true) {
        # List available profiles
        Write-Host "`nAvailable profiles:"
        for ($i = 0; $i -lt $settings.profiles.list.Count; $i++) {
            Write-Host "$i. $($settings.profiles.list[$i].name)"
        }
        Write-Host "a. Set for all profiles"
        Write-Host "d. Done"

        $choice = Read-Host "`nEnter the number of the profile to modify, 'a' for all, or 'd' when done"

        switch ($choice.ToLower()) {
            'a' {
                for ($i = 0; $i -lt $settings.profiles.list.Count; $i++) {
                    Set-ProfileColorScheme -profileIndex $i
                }
                break 2  # Exit the loop after setting all profiles
            }
            'd' {
                break 2  # Exit the loop
            }
            default {
                if ([int]::TryParse($choice, [ref]$null)) {
                    $profileIndex = [int]$choice
                    if ($profileIndex -ge 0 -and $profileIndex -lt $settings.profiles.list.Count) {
                        Set-ProfileColorScheme -profileIndex $profileIndex
                    } else {
                        Write-Host "Invalid profile number. Please try again."
                    }
                } else {
                    Write-Host "Invalid input. Please enter a number, 'a', or 'd'."
                }
            }
        }
    }
}

# Save the updated settings
$settings | ConvertTo-Json -Depth 32 | Set-Content $settingsPath

Write-Host "`nColor scheme 'Perfect' has been added successfully!"
Write-Host "Please restart Windows Terminal for changes to take effect."