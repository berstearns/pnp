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

# Install essential dependencies FIRST (before anything else)
echo ""
echo "Installing essential dependencies..."
if [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -S --noconfirm --needed base-devel openssl zlib bzip2 readline sqlite wget curl git xz tk libffi
else
    sudo apt-get install -y \
        curl \
        git \
        wget \
        ca-certificates \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        llvm \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev
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

#######################################
# PYENV INSTALLATION - ROBUST STRATEGY
#######################################
install_pyenv() {
    echo ""
    echo "Installing pyenv..."

    export PYENV_ROOT="$HOME/.pyenv"

    # Check if already installed and working
    if [ -d "$PYENV_ROOT" ] && [ -x "$PYENV_ROOT/bin/pyenv" ]; then
        echo "pyenv is already installed at $PYENV_ROOT"
        return 0
    fi

    # Clean up any partial installation
    if [ -d "$PYENV_ROOT" ]; then
        echo "Removing incomplete pyenv installation..."
        rm -rf "$PYENV_ROOT"
    fi

    echo "Attempting pyenv installation..."

    # METHOD 1: Official installer script
    echo "  Method 1: Trying official pyenv-installer..."
    if curl -fsSL https://pyenv.run | bash; then
        if [ -x "$PYENV_ROOT/bin/pyenv" ]; then
            echo "  SUCCESS: pyenv installed via official installer"
            return 0
        fi
    fi
    echo "  Method 1 failed, trying next method..."

    # Clean up if method 1 failed partially
    [ -d "$PYENV_ROOT" ] && rm -rf "$PYENV_ROOT"

    # METHOD 2: Direct git clone
    echo "  Method 2: Trying direct git clone..."
    if git clone --depth 1 https://github.com/pyenv/pyenv.git "$PYENV_ROOT"; then
        # Also clone pyenv-virtualenv plugin
        git clone --depth 1 https://github.com/pyenv/pyenv-virtualenv.git "$PYENV_ROOT/plugins/pyenv-virtualenv" 2>/dev/null || true
        # Also clone pyenv-update plugin
        git clone --depth 1 https://github.com/pyenv/pyenv-update.git "$PYENV_ROOT/plugins/pyenv-update" 2>/dev/null || true

        if [ -x "$PYENV_ROOT/bin/pyenv" ]; then
            echo "  SUCCESS: pyenv installed via git clone"
            return 0
        fi
    fi
    echo "  Method 2 failed, trying next method..."

    # Clean up if method 2 failed
    [ -d "$PYENV_ROOT" ] && rm -rf "$PYENV_ROOT"

    # METHOD 3: Download tarball from GitHub releases
    echo "  Method 3: Trying GitHub tarball download..."
    mkdir -p "$PYENV_ROOT"
    LATEST_TAG=$(curl -fsSL https://api.github.com/repos/pyenv/pyenv/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -n "$LATEST_TAG" ]; then
        if curl -fsSL "https://github.com/pyenv/pyenv/archive/refs/tags/${LATEST_TAG}.tar.gz" | tar -xz -C "$PYENV_ROOT" --strip-components=1; then
            if [ -x "$PYENV_ROOT/bin/pyenv" ]; then
                echo "  SUCCESS: pyenv installed via tarball"
                return 0
            fi
        fi
    fi
    echo "  Method 3 failed, trying next method..."

    # Clean up if method 3 failed
    [ -d "$PYENV_ROOT" ] && rm -rf "$PYENV_ROOT"

    # METHOD 4: Use wget instead of curl
    echo "  Method 4: Trying wget fallback..."
    if wget -qO- https://pyenv.run | bash; then
        if [ -x "$PYENV_ROOT/bin/pyenv" ]; then
            echo "  SUCCESS: pyenv installed via wget"
            return 0
        fi
    fi

    # All methods failed
    echo ""
    echo "ERROR: All pyenv installation methods failed!"
    echo "Please install manually: https://github.com/pyenv/pyenv#installation"
    return 1
}

# Configure shell for pyenv
configure_pyenv_shell() {
    export PYENV_ROOT="$HOME/.pyenv"

    # Determine shell config file
    SHELL_CONFIG=""
    if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
        SHELL_CONFIG="$HOME/.zshrc"
    fi
    if [ -f "$HOME/.bashrc" ]; then
        SHELL_CONFIG="$HOME/.bashrc"
    fi
    if [ -f "$HOME/.bash_profile" ]; then
        # Some systems use .bash_profile instead
        BASH_PROFILE="$HOME/.bash_profile"
    fi

    PYENV_CONFIG='
# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
'

    # Add to .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q 'PYENV_ROOT' "$HOME/.bashrc" 2>/dev/null; then
            echo "$PYENV_CONFIG" >> "$HOME/.bashrc"
            echo "Added pyenv config to ~/.bashrc"
        fi
    fi

    # Add to .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q 'PYENV_ROOT' "$HOME/.zshrc" 2>/dev/null; then
            echo "$PYENV_CONFIG" >> "$HOME/.zshrc"
            echo "Added pyenv config to ~/.zshrc"
        fi
    fi

    # Add to .profile for login shells
    if [ -f "$HOME/.profile" ]; then
        if ! grep -q 'PYENV_ROOT' "$HOME/.profile" 2>/dev/null; then
            echo "$PYENV_CONFIG" >> "$HOME/.profile"
            echo "Added pyenv config to ~/.profile"
        fi
    fi

    # Export for current session
    export PATH="$PYENV_ROOT/bin:$PATH"
}

# Run pyenv installation
if [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -S --noconfirm --needed pyenv
    export PYENV_ROOT="$HOME/.pyenv"
else
    install_pyenv
fi

# Configure shell
configure_pyenv_shell

# Verify pyenv installation
echo ""
echo "Verifying pyenv installation..."
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &> /dev/null || [ -x "$PYENV_ROOT/bin/pyenv" ]; then
    PYENV_VER=$("$PYENV_ROOT/bin/pyenv" --version 2>/dev/null || pyenv --version 2>/dev/null || echo "unknown")
    echo "pyenv verification: OK ($PYENV_VER)"
else
    echo "WARNING: pyenv installation could not be verified"
fi

# Install Docker
echo ""
echo "Installing Docker..."
if [ "$PKG_MANAGER" = "pacman" ]; then
    sudo pacman -S --noconfirm --needed docker
else
    sudo apt-get install -y docker.io
fi
sudo systemctl start docker || true
sudo systemctl enable docker || true

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Installed tools:"
echo "  - rclone: $(rclone --version 2>/dev/null | head -n 1 || echo 'not found')"
echo "  - gh: $(gh --version 2>/dev/null | head -n 1 || echo 'not found')"
if [ -x "$PYENV_ROOT/bin/pyenv" ]; then
    echo "  - pyenv: $($PYENV_ROOT/bin/pyenv --version 2>/dev/null)"
else
    echo "  - pyenv: $(pyenv --version 2>/dev/null || echo 'installed - restart shell to use')"
fi
echo "  - docker: $(docker --version 2>/dev/null || echo 'not found')"
echo ""
echo "========================================="
echo "IMPORTANT: To use pyenv, either:"
echo "  1. Run: source ~/.bashrc"
echo "  2. Or start a new terminal session"
echo "========================================="
echo ""
