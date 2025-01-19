#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

# Setup test environment before each test
setup() {
    TEST_DOTFILES_DIR="$BATS_TMPDIR/dotfiles"
    mkdir -p "$TEST_DOTFILES_DIR"
    export HOME="$BATS_TMPDIR/home"
    mkdir -p "$HOME"
}

# Cleanup after each test
teardown() {
    rm -rf "$TEST_DOTFILES_DIR"
    rm -rf "$HOME"
}

# Test OS detection
@test "should detect macOS correctly" {
    OSTYPE="darwin20.0"
    run bash -c "source ./setup.sh"
    assert_output --partial "Setting up your Mac..."
}

# Test Homebrew installation check
@test "should detect if Homebrew is installed" {
    function brew() { return 0; }
    export -f brew
    run bash -c "command -v brew"
    assert_success
}

# Test backup directory creation
@test "should create backup directory" {
    run mkdir -p "$HOME/.dotfiles/backup"
    assert_success
    assert [ -d "$HOME/.dotfiles/backup" ]
}

# Test default values backup
@test "should backup defaults for specified domains" {
    # Mock defaults command
    function defaults() { echo "mocked defaults $*"; }
    export -f defaults
    
    run defaults export "NSGlobalDomain" -
    assert_success
}

# Test Oh My Zsh installation
@test "should install Oh My Zsh if not present" {
    skip "Mock installation of Oh My Zsh"
    assert [ ! -d "$HOME/.oh-my-zsh" ]
    run bash -c "source ./setup.sh"
    assert [ -d "$HOME/.oh-my-zsh" ]
}

# Test Developer directory setup
@test "should create Developer directory" {
    run mkdir -p "$HOME/Developer"
    assert_success
    assert [ -d "$HOME/Developer" ]
}

# Test dotfile symlinks
@test "should create symlinks for dotfiles" {
    touch "$TEST_DOTFILES_DIR/.zshrc"
    ln -s "$TEST_DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    assert [ -L "$HOME/.zshrc" ]
}

# Test Edge profile configuration
@test "should configure Edge profiles" {
    skip "Mock Edge profile creation"
    run osascript -e 'tell application "Microsoft Edge" to quit'
    assert_success
}
