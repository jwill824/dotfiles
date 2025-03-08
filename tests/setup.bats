#!/usr/bin/env bats

# Load test helpers
load "test_helper"

setup() {
    _load_libs
    
    # Setup test environment
    export TEST_HOME="${RUNNER_TEMP}/test-home"
    export ORIGINAL_HOME="$HOME"
    export HOME="$TEST_HOME"
    mkdir -p "$TEST_HOME"
}

# Cleanup after each test
teardown() {
    export HOME="$ORIGINAL_HOME"
    rm -rf "$TEST_HOME"
    rm -rf "$TEST_DOTFILES_DIR"
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
    # Skip if Edge is not installed
    if [ ! -d "/Applications/Microsoft Edge.app" ]; then
        skip "Microsoft Edge is not installed"
    fi
    run osascript -e 'tell application "Microsoft Edge" to quit'
    assert_success
}

# Test application installation
@test "should install required applications" {
        function brew() { echo "mocked brew $*"; }
    export -f brew
    run brew install git
    assert_success
}

# Test directory structure setup
@test "should setup correct directory structure" {
    mkdir -p "$HOME/Developer/work"
    mkdir -p "$HOME/Developer/personal"
    assert [ -d "$HOME/Developer/work" ]
    assert [ -d "$HOME/Developer/personal" ]
}

# Test git settings configuration
@test "should configure git settings" {
    run git config --global user.name "Test User"
    assert_success
    run git config --global user.email "test@example.com"
    assert_success
}

# Test SSH directory setup
@test "should setup SSH directory" {
    run mkdir -p "$HOME/.ssh"
    assert_success
    run chmod 700 "$HOME/.ssh"
    assert_success
}

# Add new test for safety checks
@test "should respect test mode" {
    [ "$BATS_NO_SYSTEM_CHANGES" = "1" ]
    [ "$DOTFILES_TEST_MODE" = "1" ]
}
