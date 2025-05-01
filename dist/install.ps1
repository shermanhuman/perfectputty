# Perfect Environment Installer for Windows
# This script installs the Perfect environment configuration for Windows
# Version: 2.0.6
# Generated on 2025-05-01

# Define color constants
$Purple = [System.ConsoleColor]::Magenta    # 74569b - Headers, section titles
$Mint = [System.ConsoleColor]::Green        # 96fbc7 - Success messages
$Lemon = [System.ConsoleColor]::Yellow      # f7ffae - Warnings, prompts
$Pink = [System.ConsoleColor]::Red          # ffb3cb - Errors
$Lavender = [System.ConsoleColor]::Blue     # d8bfd8 - Info messages

# Define repository information
$repoOwner = "shermanhuman"
$repoName = "perfectputty"
$branch = "master"
$repoBaseUrl = "https://raw.githubusercontent.com/$repoOwner/$repoName/$branch"

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Warning "Please run as administrator for full functionality!"
  $continue = Read-Host "Continue anyway? (y/n)"
  if ($continue -ne "y") {
    exit
  }
}

# Create a unique temporary directory
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "PerfectPutty_$([System.Guid]::NewGuid().ToString())"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Write-Host "Created temporary directory: $tempDir" -ForegroundColor $Lavender

# Define file manifest
$filesToDownload = @(
    "core/profiles/powershell.ps1",
    "core/terminal/windows.json",
    "core/color-schemes/perfect16.yaml",
    "core/sounds/pop.wav",
    "dist/shell-themes/perfect.toml",
    "addons/nodejs/config.yaml",
    "addons/nodejs/install-scripts/windows.ps1",
    "addons/putty/config.yaml",
    "addons/putty/install-scripts/windows.ps1",
    "dist/addons/putty/putty-settings.reg",
    "addons/python/config.yaml",
    "addons/python/install-scripts/windows.ps1",
    "tests/run-tests.ps1",
    "tests/common/colortest.ps1",
    "tests/common/unicode-test.ps1",
    "tests/common/ascii/big.ascii",
    "tests/common/ascii/circle.ascii",
    "tests/common/ascii/future.ascii",
    "tests/common/ascii/mike.ascii",
    "tests/common/ascii/pagga.ascii"
)

# Spinner animation function
function Show-DownloadProgress {
    param (
        [int]$CurrentFile,
        [int]$TotalFiles,
        [string]$FileName,
        [string]$FileSize
    )
    
    # Use Unicode Braille characters created from code points
    # This method works correctly with PowerShell's character handling
    try {
        # These are the Unicode code points for the Braille characters
        # ⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏
        $brailleCodePoints = @(0x280B, 0x2819, 0x2839, 0x2838, 0x283C, 0x2834, 0x2826, 0x2827, 0x2807, 0x280F)
        $index = $CurrentFile % $brailleCodePoints.Count
        $spinner = [char]::ConvertFromUtf32($brailleCodePoints[$index])
    }
    catch {
        # Fallback to ASCII if there's any issue
        $asciiSpinnerChars = @('-', '\', '|', '/')
        $index = $CurrentFile % $asciiSpinnerChars.Count
        $spinner = $asciiSpinnerChars[$index]
    }
    
    # Format the status line according to user's preferred format
    $statusLine = "$spinner [$CurrentFile/$TotalFiles] Downloading ($FileSize) $FileName"
    
    # Clear the line and write the new status
    $clearLine = " " * 100
    Write-Host "`r$clearLine" -NoNewline
    Write-Host "`r$statusLine" -NoNewline
}

# Download function with retry logic
function Download-FileWithRetry {
    param (
        [string]$Url,
        [string]$OutputPath,
        [int]$MaxRetries = 3,
        [int]$CurrentFile,
        [int]$TotalFiles,
        [string]$FileName
    )
    
    $attempt = 0
    $success = $false
    
    while (-not $success -and $attempt -lt $MaxRetries) {
        $attempt++
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.Headers.Add("User-Agent", "PowerShell Script")
            
            # Get file size if possible
            try {
                $request = [System.Net.WebRequest]::Create($Url)
                $request.Method = "HEAD"
                $response = $request.GetResponse()
                $totalBytes = [long]$response.Headers["Content-Length"]
                $response.Close()
                $fileSize = "{0:N2} KB" -f ($totalBytes / 1KB)
            }
            catch {
                $fileSize = "unknown size"
            }
            
            # Show download progress
            Show-DownloadProgress -CurrentFile $CurrentFile -TotalFiles $TotalFiles -FileName $FileName -FileSize $fileSize
            
            $webClient.DownloadFile($Url, $OutputPath)
            $success = $true
            return $true
        }
        catch {
            if ($attempt -lt $MaxRetries) {
                $backoffSeconds = [Math]::Pow(2, $attempt)
                $errorMsg = "⚠ [$CurrentFile/$TotalFiles] Failed, retrying in $backoffSeconds seconds... $FileName"
                Write-Host "`r$errorMsg" -ForegroundColor $Lemon -NoNewline
                Start-Sleep -Seconds $backoffSeconds
            }
            else {
                $errorMsg = "❌ [$CurrentFile/$TotalFiles] Failed after $MaxRetries attempts: $FileName"
                Write-Host "`r$errorMsg" -ForegroundColor $Pink
                return $false
            }
        }
        finally {
            if ($webClient) {
                $webClient.Dispose()
            }
        }
    }
}

# Addon registry
$AddonRegistry = @{
    "nodejs" = @{
        "Name" = "Node.js"
        "Description" = "JavaScript runtime environment with fnm version manager"
        "Platforms" = @("windows", "macos", "linux")
        "HasStarshipConfig" = $true
        "Starship" = @{
            "Module" = '$nodejs\'
            "Config" = @"
[nodejs]
format = "[$symbol($version )]($style)"
symbol = " "
style = "bold green"
"@
        }
    }
    "putty" = @{
        "Name" = "PuTTY"
        "Description" = "SSH and telnet client with custom configuration"
        "Platforms" = @("windows")
        "HasStarshipConfig" = $false
        "Starship" = $null
    }
    "python" = @{
        "Name" = "Python"
        "Description" = "Python environment with uv package manager"
        "Platforms" = @("windows", "macos", "linux")
        "HasStarshipConfig" = $true
        "Starship" = @{
            "Module" = '$python\'
            "Config" = @"
[python]
format = "[$symbol($version )(\($virtualenv\) )]($style)"
symbol = " "
style = "bold blue"
"@
        }
    }

}

# Add Starship configuration for addon
function Add-StarshipConfig {
    param (
        [string]$AddonName
    )
    
    $starshipConfigPath = "$env:USERPROFILE\.config\starship.toml"
    
    # Check if Starship is installed and configured
    if (Test-Path $starshipConfigPath) {
        if ($AddonRegistry.ContainsKey($AddonName) -and $AddonRegistry[$AddonName].HasStarshipConfig) {
            Write-Host "Adding $AddonName configuration to Starship..." -ForegroundColor $Purple
            
            # Read the current config
            $currentConfig = Get-Content -Path $starshipConfigPath -Raw
            
            # Get addon module and config
            $addonModule = $AddonRegistry[$AddonName].Starship.Module
            $addonConfig = $AddonRegistry[$AddonName].Starship.Config
            
            # Replace module placeholder
            $newConfig = $currentConfig -replace "# ADDON_MODULES_PLACEHOLDER #", "$addonModule`n# ADDON_MODULES_PLACEHOLDER #"
            
            # Add config
            $newConfig = $newConfig -replace "# ADDON_CONFIGS_PLACEHOLDER #", "$addonConfig`n# ADDON_CONFIGS_PLACEHOLDER #"
            
            # Write the new config
            Set-Content -Path $starshipConfigPath -Value $newConfig
            
            Write-Host "$AddonName configuration added to Starship successfully!" -ForegroundColor $Mint
        }
    }
}

try {
    # Download all files
    $totalFiles = $filesToDownload.Count
    $currentFile = 0
    $failedFiles = 0
    
    foreach ($file in $filesToDownload) {
        $currentFile++
        $url = "$repoBaseUrl/$file"
        $outputPath = Join-Path $tempDir $file
        
        # Create directory structure
        $outputDir = Split-Path $outputPath
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
        }
        
        if (-not (Download-FileWithRetry -Url $url -OutputPath $outputPath -CurrentFile $currentFile -TotalFiles $totalFiles -FileName $file)) {
            $failedFiles++
        }
        
        # Small delay to make the spinner animation visible
        Start-Sleep -Milliseconds 50
    }
    
    # Clear the progress line when done
    Write-Host "`r$((" " * 100))" -NoNewline
    Write-Host "`r" -NoNewline
    
    if ($failedFiles -gt 0) {
        Write-Host "$failedFiles files failed to download. Aborting installation." -ForegroundColor $Pink
        exit 1
    }
    
    # Print success message on the same line where the spinner was
    # Use the same approach that worked for the spinner characters
    try {
        # Create the six dot braille character (⠿) using its Unicode code point
        # This is the same method that worked for the spinner characters
        $sixDotBraille = [char]::ConvertFromUtf32(0x283F)
        
        # Use the character in the success message with a carriage return
        Write-Host "`r$sixDotBraille All files downloaded successfully!" -ForegroundColor $Mint
    }
    catch {
        # Fallback if there's any issue with the Unicode character
        Write-Host "`rAll files downloaded successfully!" -ForegroundColor $Mint
    }
    
    # Check if PowerShell-YAML module is installed
    if (-not (Get-Module -ListAvailable -Name powershell-yaml)) {
        Write-Host "Installing PowerShell-YAML module..." -ForegroundColor $Purple
        Install-Module -Name powershell-yaml -Scope CurrentUser -Force
    }
    
    # Import the module
    Import-Module powershell-yaml
    
    # Create default user-config.yaml
    $configPath = Join-Path $tempDir "user-config.yaml"
    $defaultConfig = @{
        colorScheme = "Perfect16"
        font = @{
            family = "SauceCodePro Nerd Font"
            size = 12
        }
        terminal = @{
            scrollback = 10000
        }
        shell = @{
            theme = "perfect"
        }
    }
    
    # Convert to YAML and save
    $yamlContent = ConvertTo-Yaml $defaultConfig
    $yamlContent = "# Global user configuration`n" + $yamlContent
    Set-Content -Path $configPath -Value $yamlContent
    
    Write-Host "Created default user configuration at $configPath" -ForegroundColor $Mint
    
    # Install core components
    Write-Host "Installing core components..." -ForegroundColor $Purple
    
    # PowerShell profile content
    $profileContent = Get-Content -Path (Join-Path $tempDir "core/profiles/powershell.ps1") -Raw
    
    # Install PowerShell profile
    $profileDir = Split-Path $PROFILE
    $profilePath = $PROFILE
    
    # Create profile directory if it doesn't exist
    if (-not (Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    }
    
    # Create a backup of the existing profile if it exists
    if (Test-Path $profilePath) {
        $backupDir = Join-Path $env:USERPROFILE "PerfectPutty_Backups"
        if (-not (Test-Path $backupDir)) {
            New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        }
        
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupFile = Join-Path $backupDir "PowerShell_Profile_Backup_$timestamp.ps1"
        
        Write-Host "Creating backup of PowerShell profile to $backupFile..." -ForegroundColor $Purple
        Copy-Item -Path $profilePath -Destination $backupFile -Force
        Write-Host "PowerShell profile backup created successfully!" -ForegroundColor $Mint
    }
    
    # Write profile
    try {
        Set-Content -Path $profilePath -Value $profileContent
        Write-Host "PowerShell profile installed to $profilePath" -ForegroundColor $Mint
    } catch {
        Write-Host "Error installing PowerShell profile: $_" -ForegroundColor $Pink
        
        if (Test-Path $backupFile) {
            $restore = Read-Host "Would you like to restore from backup? (y/n)"
            if ($restore -eq "y") {
                Write-Host "Restoring PowerShell profile from $backupFile..." -ForegroundColor $Lemon
                Copy-Item -Path $backupFile -Destination $profilePath -Force
                Write-Host "PowerShell profile restored successfully!" -ForegroundColor $Mint
            }
        }
    }
    
    # Windows Terminal color scheme
    $colorSchemeJson = Get-Content -Path (Join-Path $tempDir "core/terminal/windows.json") -Raw
    $colorScheme = $colorSchemeJson | ConvertFrom-Json
    
    # Install Windows Terminal color scheme
    Write-Host "Installing Windows Terminal configuration..." -ForegroundColor $Purple
    $wtSettings = "$env:LocalAppData\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $wtPreviewSettings = "$env:LocalAppData\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    
    $settingsPath = ""
    if (Test-Path $wtSettings) {
        $settingsPath = $wtSettings
    } elseif (Test-Path $wtPreviewSettings) {
        $settingsPath = $wtPreviewSettings
    }
    
    if ($settingsPath) {
        try {
            # Create a backup of the settings file
            $backupDir = Join-Path $env:USERPROFILE "PerfectPutty_Backups"
            if (-not (Test-Path $backupDir)) {
                New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
            }
            
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $backupPath = Join-Path $backupDir "WindowsTerminal_Settings_Backup_$timestamp.json"
            Copy-Item -Path $settingsPath -Destination $backupPath -Force
            Write-Host "Created backup of Windows Terminal settings at $backupPath" -ForegroundColor $Mint
            
            # Read the settings file
            $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
            
            # Handle schemes property based on its type
            if ($null -eq $settings.schemes) {
                # If schemes doesn't exist, create it as an array
                $settings | Add-Member -Type NoteProperty -Name schemes -Value @($colorScheme)
            } elseif ($settings.schemes -is [System.Array]) {
                # If schemes is already an array, remove existing scheme with the same name
                $settings.schemes = @($settings.schemes | Where-Object { $_.name -ne $colorScheme.name })
                # Add the new color scheme
                $settings.schemes += $colorScheme
            } else {
                # If schemes exists but is not an array (e.g., it's an object), convert it to an array
                $existingScheme = $settings.schemes
                $schemeArray = @()
                
                # Only add the existing scheme if it's not the same name as our new one
                if ($existingScheme.name -ne $colorScheme.name) {
                    $schemeArray += $existingScheme
                }
                
                # Add our new scheme
                $schemeArray += $colorScheme
                
                # Replace the schemes property with the array
                $settings.PSObject.Properties.Remove('schemes')
                $settings | Add-Member -Type NoteProperty -Name schemes -Value $schemeArray
            }
            
            # Save the updated settings
            $settingsJson = ConvertTo-Json -InputObject $settings -Depth 32
            Set-Content -Path $settingsPath -Value $settingsJson
            
            Write-Host "Windows Terminal color scheme installed successfully!" -ForegroundColor $Mint
        } catch {
            Write-Host "Error updating Windows Terminal settings: $_" -ForegroundColor $Pink
            Write-Host "Restoring backup..." -ForegroundColor $Lemon
            
            # Restore from backup if it exists
            if (Test-Path $backupPath) {
                Copy-Item -Path $backupPath -Destination $settingsPath -Force
                Write-Host "Settings restored from backup." -ForegroundColor $Mint
            }
        }
    } else {
        Write-Host "Windows Terminal settings file not found" -ForegroundColor $Lemon
    }
    
    # Install Starship
    Write-Host "Installing Starship..." -ForegroundColor $Purple
    
    # Check if winget is available
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install --id Starship.Starship
        
        # Refresh PATH after winget installation to detect newly installed Starship
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } else {
        # Fallback to direct installation
        Invoke-WebRequest -Uri https://starship.rs/install.ps1 -OutFile $env:TEMP\install-starship.ps1
        & $env:TEMP\install-starship.ps1 -BinDir "$env:USERPROFILE\.local\bin"
        
        # Add to PATH if not already there
        $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($userPath -notlike "*$env:USERPROFILE\.local\bin*") {
            [Environment]::SetEnvironmentVariable("PATH", "$userPath;$env:USERPROFILE\.local\bin", "User")
            $env:PATH = "$env:PATH;$env:USERPROFILE\.local\bin"
        }
    }
    
    # Verify Starship installation
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Write-Host "Starship installed successfully!" -ForegroundColor $Mint
        
        # Get theme name from config
        $config = Get-Content -Path $configPath -Raw | ConvertFrom-Yaml
        $themeName = $config.shell.theme
        
        # Copy theme file
        $themePath = Join-Path $tempDir "dist/shell-themes/$themeName.toml"
        $themeDestPath = Join-Path $env:USERPROFILE ".config"
        
        # Create config directory if it doesn't exist
        if (-not (Test-Path $themeDestPath)) {
            New-Item -Path $themeDestPath -ItemType Directory -Force | Out-Null
        }
        
        # Copy theme file
        Copy-Item -Path $themePath -Destination "$themeDestPath\starship.toml" -Force
        
        # Update PowerShell profile to use Starship
        $profileContent = $profileContent -replace "function prompt \{.*?\}", "# Using Starship for prompt`nInvoke-Expression (&starship init powershell)"
        Set-Content -Path $profilePath -Value $profileContent
        
        Write-Host "Starship configured successfully!" -ForegroundColor $Mint
    } else {
        Write-Host "Starship installation failed. Using fallback prompt." -ForegroundColor $Lemon
    }
    
    # Install fonts
    Write-Host "Would you like to install the SauceCodePro Nerd Font? (y/n): " -NoNewline
    $installFonts = Read-Host
    
    if ($installFonts -eq "y") {
        Write-Host "Downloading SauceCodePro Nerd Font..." -ForegroundColor $Purple
        $fontUrl = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/SourceCodePro.zip"
        $fontZip = "$env:TEMP\SauceCodePro.zip"
        $fontDir = "$env:TEMP\SauceCodePro"
        
        # Download font
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "PowerShell Script")
        $webClient.DownloadFile($fontUrl, $fontZip)
        
        # Extract font
        Expand-Archive -Path $fontZip -DestinationPath $fontDir -Force
        
        # Install font silently (without confirmation dialogs)
        $fonts = (New-Object -ComObject Shell.Application).Namespace(0x14)
        $fontCount = (Get-ChildItem -Path $fontDir -Filter "*.ttf").Count
        Write-Host "Installing $fontCount font variations silently..." -ForegroundColor Cyan
        
        # Use option flags for silent installation:
        # 0x4 = Do not display a progress dialog box
        # 0x10 = Respond with "Yes to All" for any dialog box
        # 0x14 = Combine both options
        Get-ChildItem -Path $fontDir -Filter "*.ttf" | ForEach-Object {
            # Using 0x14 (20 in decimal) to suppress all dialogs
            $fonts.CopyHere($_.FullName, 0x14)
            # Small sleep to prevent potential issues with rapid installation
            Start-Sleep -Milliseconds 100
        }
        
        # Clean up
        Remove-Item -Path $fontZip -Force
        Remove-Item -Path $fontDir -Recurse -Force
        
        Write-Host "Fonts installed successfully!" -ForegroundColor $Mint
    }
    
    # Process add-ons
    Write-Host "Would you like to install add-ons? (y/n): " -NoNewline
    $installAddons = Read-Host
    
    if ($installAddons -eq "y") {
        $addonsDir = Join-Path $tempDir "addons"
        $addons = @()
        
        # Scan add-ons
        Get-ChildItem -Path $addonsDir -Directory | ForEach-Object {
            $configPath = Join-Path $_.FullName "config.yaml"
            if (Test-Path $configPath) {
                $yamlContent = Get-Content $configPath -Raw
                $config = ConvertFrom-Yaml $yamlContent
                $addons += @{
                    Name = $config.name
                    Description = $config.description
                    Path = $_.FullName
                    Platforms = $config.platforms
                }
            }
        }
        
        # Present add-on menu
        if ($addons.Count -eq 0) {
            Write-Host "No add-ons available." -ForegroundColor Yellow
        } else {
            Write-Host "`n=== Available Add-ons ===" -ForegroundColor $Purple
            
            $selected = @()
            for ($i = 0; $i -lt $addons.Count; $i++) {
                $isWindowsCompatible = $addons[$i].Platforms -contains "windows"
                
                if ($isWindowsCompatible) {
                    Write-Host "[ ] $($i+1). $($addons[$i].Name) - $($addons[$i].Description)"
                    $selected += $false
                }
            }
            
            while ($true) {
                Write-Host "`nEnter numbers to toggle selection (e.g., '1 3'), or press Enter to continue: " -NoNewline
                $input = Read-Host
                
                if ([string]::IsNullOrEmpty($input)) {
                    break
                }
                
                $input.Split(" ") | ForEach-Object {
                    if ($_ -match "^\d+$") {
                        $index = [int]$_ - 1
                        if ($index -ge 0 -and $index -lt $addons.Count) {
                            $selected[$index] = -not $selected[$index]
                            $mark = if ($selected[$index]) { "[x]" } else { "[ ]" }
                            Write-Host "$mark $($index+1). $($addons[$index].Name)"
                        }
                    }
                }
            }
            
            # Install selected add-ons
            for ($i = 0; $i -lt $addons.Count; $i++) {
                if ($selected[$i]) {
                    $addon = $addons[$i]
                    Write-Host "Installing add-on: $($addon.Name)" -ForegroundColor $Purple
                    
                    $scriptPath = Join-Path $addon.Path "install-scripts/windows.ps1"
                    if (Test-Path $scriptPath) {
                        # Execute the add-on installation script
                        & $scriptPath
                        
                        # Add Starship configuration if available
                        Add-StarshipConfig -AddonName (Split-Path $addon.Path -Leaf)
                    } else {
                        Write-Host "No installation script found for $($addon.Name) on Windows" -ForegroundColor $Lemon
                    }
                }
            }
        }
    }
    
    # Offer to run tests
    Write-Host "`nWould you like to run tests to verify your installation? (y/n): " -NoNewline
    $runTests = Read-Host
    
    if ($runTests -eq "y") {
        $testsPath = Join-Path $tempDir "tests/run-tests.ps1"
        if (Test-Path $testsPath) {
            & $testsPath
        } else {
            Write-Host "Tests not found at $testsPath" -ForegroundColor Yellow
        }
    }
    
    Write-Host "Installation complete!" -ForegroundColor $Mint
}
finally {
    # Clean up temporary directory
    if (Test-Path $tempDir) {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Cleaned up temporary directory" -ForegroundColor $Lavender
    }
}