#!/bin/bash

# Quick Start Script for Fresh Linux Environment
# This script installs essential tools: rclone and gh cli

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

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
echo "Installed tools:"
echo "  - rclone: $(rclone --version | head -n 1)"
echo "  - gh: $(gh --version | head -n 1)"
echo ""
