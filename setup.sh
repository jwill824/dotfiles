#!/bin/bash

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
    echo "Windows detected. Please use setup.ps1 instead."
    echo "Run: powershell -ExecutionPolicy Bypass -File setup.ps1"
    exit 1
else
    echo "Unsupported operating system"
    exit 1
fi

# Ensure script fails on error
set -e

echo "Setting up your Mac..."

# Backup original defaults
echo "Backing up original defaults..."
BACKUP_DIR="$HOME/.dotfiles/backup"
mkdir -p "$BACKUP_DIR"

# Backup all relevant domains
domains=(
    "NSGlobalDomain"
    "com.apple.screencapture"
    "com.apple.finder"
    "com.apple.dock"
)

for domain in "${domains[@]}"; do
    defaults export "$domain" "$BACKUP_DIR/${domain}.plist" 2>/dev/null || true
done

# Check if running from curl
if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Cloning dotfiles repository..."
    git clone https://github.com/yourusername/dotfiles.git "$HOME/.dotfiles"
    cd "$HOME/.dotfiles"
fi

# Install Homebrew if not installed
if test ! $(which brew); then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install all dependencies from Brewfile
brew bundle

# Install Oh My Zsh if not installed
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install spaceship-prompt
git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
ZSH_THEME="spaceship"

# Install zsh-autosuggestions and zsh-syntax-highlighting
sudo git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Create Developer directory and clone repositories
echo "Setting up development environment..."
mkdir -p "$HOME/Developer"
cd "$HOME/Developer"

# Clone repos first
git clone https://github.com/jwill824/repos.git
cd repos
mkdir -p personal
cd personal

# Clone dotfiles repository
git clone https://github.com/yourusername/dotfiles.git
cd dotfiles

# Create symbolic link for .zshrc
echo "Setting up .zshrc..."
ln -sf "$HOME/.dotfiles/.zshrc" "$HOME/.zshrc"

# Create symbolic link for .hyper.js
echo "Setting up Hyper configuration..."
ln -sf "$HOME/.dotfiles/.hyper.js" "$HOME/.hyper.js"

# macOS Defaults
echo "Configuring macOS defaults..."

# Keyboard
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Screenshots
defaults write com.apple.screencapture location -string "${HOME}/Downloads"

# Finder
defaults write com.apple.finder AppleShowAllFiles YES
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Dock
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock static-only -bool true

# Hot Corners
defaults write com.apple.dock wvous-bl-corner -int 5
defaults write com.apple.dock wvous-bl-modifier -int 0

# Configure Edge Profiles
echo "Configuring Microsoft Edge profiles..."
EDGE_PROFILES=$(cat "$HOME/.dotfiles/edge-profiles.json")

# Create AppleScript to configure Edge profiles
osascript <<EOD
tell application "Microsoft Edge"
    activate
    delay 2 # Wait for Edge to open
    
    # Add profiles from JSON
    set profiles to (do shell script "echo '$EDGE_PROFILES' | /usr/bin/plutil -convert xml1 - -o - | xpath -e '//profiles/item/name/text()' 2>/dev/null")
    
    repeat with profile_name in profiles
        tell application "System Events"
            tell process "Microsoft Edge"
                # Click profile menu
                click menu item "Add profile..." of menu "Profiles" of menu bar 1
                delay 1
                
                # Enter profile name
                keystroke profile_name
                delay 1
                
                # Confirm profile creation
                click button "Create" of window 1
                delay 2
            end tell
        end tell
    end repeat
    
    quit
end tell
EOD

# Kill affected applications
for app in "Finder" "Dock" "SystemUIServer"; do
    killall "${app}" &> /dev/null
done

echo "Setup complete! Some changes may require a logout/restart to take effect."
