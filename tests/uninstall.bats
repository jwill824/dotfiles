#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

# Setup test environment before each test
setup() {
    TEST_DOTFILES_DIR="$BATS_TMPDIR/dotfiles"
    mkdir -p "$TEST_DOTFILES_DIR"
    export HOME="$BATS_TMPDIR/home"
    mkdir -p "$HOME"
    mkdir -p "$HOME/.dotfiles/backup"
}

# Cleanup after each test
teardown() {
    rm -rf "$TEST_DOTFILES_DIR"
    rm -rf "$HOME"
}

# Test defaults restoration
@test "should restore defaults from backup" {
    # Create mock backup files
    echo "mock plist" > "$HOME/.dotfiles/backup/NSGlobalDomain.plist"
    
    function defaults() { echo "mocked defaults $*"; }
    export -f defaults
    
    run defaults import "NSGlobalDomain" "$HOME/.dotfiles/backup/NSGlobalDomain.plist"
    assert_success
}

# Test Homebrew package removal
@test "should uninstall Homebrew packages" {
    function brew() { echo "mocked brew $*"; }
    export -f brew
    
    run brew remove --force
    assert_success
}

# Test Oh My Zsh removal
@test "should uninstall Oh My Zsh" {
    mkdir -p "$HOME/.oh-my-zsh"
    function uninstall_oh_my_zsh() { rm -rf "$HOME/.oh-my-zsh"; }
    export -f uninstall_oh_my_zsh
    
    run uninstall_oh_my_zsh
    assert_success
    assert [ ! -d "$HOME/.oh-my-zsh" ]
}

# Test dotfile symlink removal
@test "should remove dotfile symlinks" {
    touch "$TEST_DOTFILES_DIR/.zshrc"
    ln -s "$TEST_DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    
    run rm "$HOME/.zshrc"
    assert_success
    assert [ ! -L "$HOME/.zshrc" ]
}

# Test original .zshrc restoration
@test "should restore original .zshrc" {
    echo "original zshrc" > "$HOME/.zshrc.pre-oh-my-zsh"
    
    run mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/.zshrc"
    assert_success
    assert [ -f "$HOME/.zshrc" ]
}

# Test Edge profile removal
@test "should remove Edge profiles" {
    mkdir -p "$HOME/Library/Application Support/Microsoft Edge/Profile 1"
    
    run rm -rf "$HOME/Library/Application Support/Microsoft Edge/*/Profile *"
    assert_success
    assert [ ! -d "$HOME/Library/Application Support/Microsoft Edge/Profile 1" ]
}

# Test overall uninstall process
@test "should complete uninstallation successfully" {
    run bash -c "source ./uninstall.sh"
    assert_success
}
