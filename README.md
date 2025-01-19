# Dotfiles

Personal dotfiles for macOS and Windows setup and configuration.

## Prerequisites

### macOS
1. Install Xcode Command Line Tools:
    ```bash
    xcode-select --install
    ```

### Windows
1. Ensure PowerShell is running as Administrator
2. Enable script execution:
    ```powershell
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

## Installation

The setup scripts will:
1. Create ~/Developer directory
2. Clone the main repos repository
3. Create personal directory
4. Download and extract dotfiles
5. Configure system settings and install applications

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/dotfiles/main/setup.sh | bash
```

### Windows

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/yourusername/dotfiles/main/setup.ps1 -OutFile setup.ps1
.\setup.ps1
```

## Development

The dotfiles repository includes a devcontainer configuration for testing and development. After initial setup:

1. Open VS Code in the dotfiles directory:
    ```bash
    code ~/Developer/repos/personal/dotfiles
    ```
2. When prompted, select "Reopen in Container"
3. The devcontainer will setup the testing environment automatically

## What's Included

- Homebrew packages and casks installation
- macOS system preferences configuration
- Terminal and UI customizations

## Uninstalling

### macOS

```bash
./uninstall.sh
```

### Windows

```powershell
.\uninstall.ps1
```

This will:

- Remove installed applications
- Revert Windows settings
- Remove DevDrive (if created)
- Clean up development environment
- Remove dotfiles

## Manual Steps

Some things that need to be done manually after installation:

1. Restart your computer after WSL installation (Windows only)
2. Install your preferred Linux distribution from the Microsoft Store (Windows only)
3. Sign in to installed applications
4. Configure additional application-specific settings

## Testing

### Windows (PowerShell)
```powershell
# Install Pester
Install-Module -Name Pester -Force

# Run tests
Invoke-Pester ./tests
```

### macOS (Bash)
```bash
# Install Bats
brew install bats-core
brew install bats-support
brew install bats-assert

# Run tests
bats tests/
```
