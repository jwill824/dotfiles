#!/bin/bash

# Ensure script fails on error
set -e

echo "Reverting all changes..."

# Restore original macOS defaults
echo "Restoring original macOS defaults..."
BACKUP_DIR="$HOME/.dotfiles/backup"

# Restore defaults for each domain
for plist in "$BACKUP_DIR"/*.plist; do
    if [ -f "$plist" ]; then
        domain=$(basename "$plist" .plist)
        echo "Restoring defaults for $domain..."
        defaults import "$domain" "$plist"
    fi
done

# Uninstall Homebrew packages and casks
echo "Uninstalling Homebrew packages..."
if command -v brew >/dev/null 2>&1; then
    brew remove --force $(brew list --formula)
    brew remove --cask --force $(brew list --cask)
    brew cleanup
fi

# Remove Oh My Zsh
if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Removing Oh My Zsh..."
    uninstall_oh_my_zsh
fi

# Remove dotfiles symlinks
echo "Removing dotfile symlinks..."
[ -L "$HOME/.zshrc" ] && rm "$HOME/.zshrc"
[ -L "$HOME/.hyper.js" ] && rm "$HOME/.hyper.js"

# Restore original .zshrc if it exists
if [ -f "$HOME/.zshrc.pre-oh-my-zsh" ]; then
    mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc"
fi

# Remove Edge profiles
echo "Removing Microsoft Edge profiles..."
rm -rf "$HOME/Library/Application Support/Microsoft Edge/*/Profile *"

# Optionally remove Homebrew itself
read -p "Do you want to uninstall Homebrew? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
fi

# Kill affected applications
for app in "Finder" "Dock" "SystemUIServer"; do
    killall "${app}" &> /dev/null || true
done

echo "Uninstall complete! Please restart your computer for all changes to take effect."
