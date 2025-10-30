#!/bin/bash

# Quick Start Script for Fresh Linux Environment
# This script installs essential tools: rclone, gh cli, pyenv, and docker

set -e  # Exit on error

echo "========================================="
echo "Starting Quick Start Setup"
echo "========================================="

# Update package list
echo ""
echo "Updating package list..."
sudo apt-get update

# Install rclone
echo ""
echo "Installing rclone..."
sudo apt-get install -y rclone

# Install GitHub CLI
echo ""
echo "Installing GitHub CLI (gh)..."
sudo apt-get install -y gh

# Install pyenv
echo ""
echo "Installing pyenv..."
sudo apt-get install -y pyenv

# Install Docker
echo ""
echo "Installing Docker..."
sudo apt-get install -y docker.io
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
echo "  - pyenv: $(pyenv --version 2>/dev/null || echo 'installed')"
echo "  - docker: $(docker --version)"
echo ""
