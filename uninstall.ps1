# Ensure script stops on error
$ErrorActionPreference = "Stop"

Write-Host "Uninstalling Windows configurations..."

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Please run as Administrator"
    exit 1
}

# Uninstall applications from packages.json
Write-Host "Uninstalling applications..."
$packages = Get-Content -Raw -Path "$HOME\.dotfiles\packages.json" | ConvertFrom-Json
foreach ($package in $packages.winget) {
    Write-Host "Uninstalling $($package.name)..."
    winget uninstall --id $package.id
}

# Revert Windows settings
Write-Host "Reverting Windows settings..."

# Hide file extensions (revert to default)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 1

# Hide hidden files (revert to default)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 2

# Remove Windows Terminal settings if they exist
$terminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $terminalSettingsPath) {
    Write-Host "Removing custom Windows Terminal settings..."
    Remove-Item $terminalSettingsPath -Force
}

# Remove DevDrive if it exists
$devDrive = Get-VirtualDisk | Where-Object { $_.FriendlyName -eq "DevDrive" }
if ($devDrive) {
    Write-Host "Removing DevDrive..."
    $devDrive | Remove-VirtualDisk -Confirm:$false
}

# Remove Edge profiles
Write-Host "Removing Microsoft Edge profiles..."
$edgeProfilesPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
if (Test-Path $edgeProfilesPath) {
    Get-ChildItem $edgeProfilesPath -Directory | Where-Object { $_.Name -ne "Default" } | Remove-Item -Recurse -Force
}

# Clean up repositories and directories
Write-Host "Cleaning up development environment..."
if (Test-Path "$HOME\Developer") {
    Remove-Item -Path "$HOME\Developer" -Recurse -Force
}

# Remove dotfiles
Write-Host "Removing dotfiles..."
if (Test-Path "$HOME\.dotfiles") {
    Remove-Item -Path "$HOME\.dotfiles" -Recurse -Force
}

Write-Host "Uninstall complete! Please restart your computer for all changes to take effect."
