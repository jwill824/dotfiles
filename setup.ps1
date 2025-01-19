# Ensure script stops on error
$ErrorActionPreference = "Stop"

Write-Host "Setting up your Windows PC..."

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Please run as Administrator"
    exit 1
}

# Install WSL
Write-Host "Installing Windows Subsystem for Linux..."
wsl --install --no-distribution

# Enable required Windows features
Write-Host "Enabling required Windows features..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Set WSL 2 as default
Write-Host "Setting WSL 2 as default..."
wsl --set-default-version 2

# Setup DevDrive
Write-Host "Setting up DevDrive..."

# Get next available drive letter
$usedDrives = Get-PSDrive -PSProvider FileSystem | Select-Object -ExpandProperty Name
$availableLetter = [char[]](67..90) | Where-Object { $usedDrives -notcontains $_ } | Select-Object -First 1
$driveLetter = "$availableLetter`:"

# Check if Windows 11 or later (DevDrive requires Windows 11)
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
$isWin11OrLater = [System.Version]$osInfo.Version -ge [System.Version]"10.0.22000"

if ($isWin11OrLater) {
    # Check if DevDrive already exists
    $existingDevDrive = Get-VirtualDisk | Where-Object { $_.FriendlyName -eq "DevDrive" }
    
    if (-not $existingDevDrive) {
        # Create DevDrive (100GB size by default)
        New-VirtualDisk -FriendlyName "DevDrive" -Size 100GB -DevDrive
        Initialize-Disk -VirtualDisk (Get-VirtualDisk -FriendlyName "DevDrive") -PartitionStyle GPT
        $partition = New-Partition -VirtualDisk (Get-VirtualDisk -FriendlyName "DevDrive") -UseMaximumSize -DriveLetter $availableLetter
        Format-Volume -Partition $partition -FileSystem ReFS -NewFileSystemLabel "DevDrive" -Confirm:$false
        
        Write-Host "DevDrive created successfully at $driveLetter"
        
        # Update Developer directory path to use DevDrive
        $env:DEV_DRIVE = $driveLetter
        $env:DEV_PATH = "$driveLetter\Developer"
    } else {
        Write-Host "DevDrive already exists"
    }
} else {
    Write-Host "DevDrive requires Windows 11 or later. Skipping DevDrive setup."
    $env:DEV_PATH = "$HOME\Developer"
}

# Install WinGet if not present
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Installing WinGet..."
    # Note: Modern Windows 10/11 systems should have this pre-installed
    # Add installation logic if needed
}

# Install Git if not present (needed for repo clone)
if (!(Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Git..."
    winget install -e --id Git.Git
}

# Clone dotfiles repository if not exists
if (!(Test-Path "$HOME\.dotfiles")) {
    Write-Host "Cloning dotfiles repository..."
    git clone https://github.com/yourusername/dotfiles.git "$HOME\.dotfiles"
    Set-Location "$HOME\.dotfiles"
}

# Install applications from packages.json
Write-Host "Installing applications..."
$packages = Get-Content -Raw -Path "$HOME\.dotfiles\packages.json" | ConvertFrom-Json
foreach ($package in $packages.winget) {
    Write-Host "Installing $($package.name)..."
    winget install -e --id $package.id
}

# Configure Windows settings
Write-Host "Configuring Windows settings..."

# Show file extensions
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0

# Show hidden files
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1

# Create Developer directory and clone repositories
Write-Host "Setting up development environment..."
New-Item -Path $env:DEV_PATH -ItemType Directory -Force
Set-Location $env:DEV_PATH

# Clone repos first
git clone https://github.com/jwill824/repos.git
Set-Location repos
New-Item -Path "personal" -ItemType Directory -Force
Set-Location personal

# Clone dotfiles repository
git clone https://github.com/yourusername/dotfiles.git
Set-Location dotfiles

# Install Windows Terminal settings
if (Test-Path "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState") {
    Write-Host "Configuring Windows Terminal..."
    Copy-Item "$HOME\.dotfiles\windows-terminal-settings.json" `
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" -Force
}

# Configure Edge Profiles
Write-Host "Configuring Microsoft Edge profiles..."
$edgeProfiles = Get-Content -Raw -Path "$HOME\.dotfiles\edge-profiles.json" | ConvertFrom-Json

foreach ($profile in $edgeProfiles.profiles) {
    Write-Host "Creating Edge profile: $($profile.name)"
    
    # Edge profile location
    $profilePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\$($profile.name)"
    
    # Create profile directory if it doesn't exist
    if (!(Test-Path $profilePath)) {
        New-Item -Path $profilePath -ItemType Directory -Force
        
        # Create Preferences file with profile settings
        $preferences = @{
            profile = @{
                name = $profile.name
                email = $profile.email
            }
        }
        
        $preferences | ConvertTo-Json -Depth 10 | Set-Content "$profilePath\Preferences"
    }
}

Write-Host "Setup complete! Please restart your computer for all changes to take effect."
