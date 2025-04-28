# Common installer functions

function Create-DefaultConfig {
  $configPath = Join-Path $PSScriptRoot ".." "user-config.yaml"
  
  @"
# Global user configuration
colorScheme: Perfect16
font:
  family: SauceCodePro Nerd Font
  size: 12
terminal:
  scrollback: 10000
"@ | Set-Content -Path $configPath
  
  Write-Host "Created default user configuration at $configPath" -ForegroundColor Green
}

function Scan-Addons {
  $addonsDir = Join-Path $PSScriptRoot ".." "addons"
  $addons = @()
  
  if (-not (Test-Path $addonsDir)) {
    return $addons
  }
  
  Get-ChildItem -Path $addonsDir -Directory | ForEach-Object {
    $configPath = Join-Path $_.FullName "config.yaml"
    if (Test-Path $configPath) {
      $config = Get-Content $configPath -Raw | ConvertFrom-Yaml
      $addons += @{
        Name = $config.name
        Description = $config.description
        Path = $_.FullName
        Platforms = $config.platforms
      }
    }
  }
  
  return $addons
}

function Present-AddonMenu {
  param (
    [Parameter(Mandatory=$true)]
    [array]$Addons
  )
  
  $selected = @()
  
  if ($Addons.Count -eq 0) {
    Write-Host "No add-ons available." -ForegroundColor Yellow
    return $selected
  }
  
  Write-Host "`n=== Available Add-ons ===" -ForegroundColor Cyan
  
  for ($i = 0; $i -lt $Addons.Count; $i++) {
    $addon = $Addons[$i]
    $isWindowsCompatible = $addon.Platforms -contains "windows"
    
    if ($isWindowsCompatible) {
      Write-Host ("[{0}] {1}. {2} - {3}" -f " ", ($i + 1), $addon.Name, $addon.Description)
      $selected += $false
    }
  }
  
  while ($true) {
    Write-Host "`nEnter numbers to toggle selection (e.g., '1 3'), or press Enter to continue: " -NoNewline
    $input = Read-Host
    
    if ([string]::IsNullOrWhiteSpace($input)) {
      break
    }
    
    $input.Split(" ") | ForEach-Object {
      if ([int]::TryParse($_, [ref]$null)) {
        $index = [int]$_ - 1
        if ($index -ge 0 -and $index -lt $Addons.Count) {
          $selected[$index] = -not $selected[$index]
          $mark = if ($selected[$index]) { "x" } else { " " }
          Write-Host ("[{0}] {1}. {2}" -f $mark, ($index + 1), $Addons[$index].Name)
        }
      }
    }
  }
  
  $result = @()
  for ($i = 0; $i -lt $Addons.Count; $i++) {
    if ($selected[$i]) {
      $result += $Addons[$i]
    }
  }
  
  return $result
}

function Install-SelectedAddons {
  param (
    [Parameter(Mandatory=$true)]
    [array]$Selected
  )
  
  foreach ($addon in $Selected) {
    Write-Host "Installing add-on: $($addon.Name)" -ForegroundColor Cyan
    $scriptPath = Join-Path $addon.Path "windows.ps1"
    if (Test-Path $scriptPath) {
      & $scriptPath
    } else {
      Write-Host "No Windows installation script found for $($addon.Name)" -ForegroundColor Yellow
    }
  }
}

function Offer-Tests {
  Write-Host "`nWould you like to run tests to verify your installation? (y/n): " -NoNewline
  $runTests = Read-Host
  
  if ($runTests -ne "y") {
    return
  }
  
  $testsPath = Join-Path $PSScriptRoot ".." "tests" "run-tests.ps1"
  if (Test-Path $testsPath) {
    & $testsPath
  } else {
    Write-Host "Tests not found at $testsPath" -ForegroundColor Yellow
  }
}