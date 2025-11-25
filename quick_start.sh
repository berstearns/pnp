#!/bin/bash

# Quick Start Script for Fresh Linux Environment
# This script installs essential tools: rclone, gh cli, pyenv, and docker
# Supports: Arch Linux, Debian/Ubuntu

set -e  # Exit on error

echo "========================================="
echo "Starting Quick Start Setup"
echo "========================================="

# Detect package manager
if command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    echo "Detected: Arch Linux"
elif command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    echo "Detected: Debian/Ubuntu"
else
    echo "Error: Unsupported distribution (no pacman or apt-get found)"
    exit 1
fi

# Update package list
echo ""
echo "Updating package list..."
if [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -Sy --noconfirm
else
    sudo apt-get update
fi

# Install essential dependencies
echo ""
echo "Installing essential dependencies..."
if [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -S --noconfirm --needed base-devel openssl zlib bzip2 readline sqlite wget xz tk libffi
else
    sudo apt-get install -y curl git build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
fi

# Install rclone
echo ""
echo "Installing rclone..."
if [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -S --noconfirm --needed rclone
else
    sudo apt-get install -y rclone
fi

# Install GitHub CLI
echo ""
echo "Installing GitHub CLI (gh)..."
if [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -S --noconfirm --needed github-cli
else
    if ! command -v gh &> /dev/null; then
        sudo mkdir -p -m 755 /etc/apt/keyrings
        wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
        sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y gh
    else
        echo "gh is already installed"
    fi
fi

# Install pyenv
echo ""
echo "Installing pyenv..."
if [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -S --noconfirm --needed pyenv
else
    if [ ! -d "$HOME/.pyenv" ]; then
        curl https://pyenv.run | bash
    else
        echo "pyenv is already installed"
    fi
fi

# Add pyenv to shell configuration if not already present
if ! grep -q 'PYENV_ROOT' ~/.bashrc 2>/dev/null; then
    echo '' >> ~/.bashrc
    echo '# pyenv configuration' >> ~/.bashrc
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
fi

# Export pyenv for current session
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# Install Docker
echo ""
echo "Installing Docker..."
if [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -S --noconfirm --needed docker
else
    sudo apt-get install -y docker.io
fi
sudo systemctl start docker
sudo systemctl enable docker

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Installed tools:"
echo "  - rclone: $(rclone --version | head -n 1)"
echo "  - gh: $(gh --version | head -n 1)"
echo "  - pyenv: $(pyenv --version 2>/dev/null || echo 'installed - restart shell to use')"
echo "  - docker: $(docker --version)"
echo ""
echo "NOTE: Run 'source ~/.bashrc' or restart your terminal to use pyenv"
echo ""
