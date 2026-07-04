#!/bin/bash

# Script for automatic installation of Docker, Docker Compose, Python, and Django

# Exit on error
set -e

echo "Starting the checking and installation of tools..."

# Update package lists
sudo apt-get update -y

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Install Docker
if command_exists docker; then
    echo "Docker is already installed: $(docker --version)"
else
    echo "Installing Docker..."
    sudo apt-get install -y docker.io
    echo "Docker successfully installed."
fi

# 2. Install Docker Compose
if command_exists docker-compose; then
    echo "Docker Compose is already installed: $(docker-compose --version)"
elif docker compose version >/dev/null 2>&1; then
    echo "Docker Compose (plugin) is already installed: $(docker compose version)"
else
    echo "Installing Docker Compose..."
    sudo apt-get install -y docker-compose
    echo "Docker Compose successfully installed."
fi

# 3. Install Python (3.9 or newer)
if command_exists python3; then
    echo "Python 3 is already installed: $(python3 --version)"
    # Check version (must be >= 3.9)
    if python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)'; then
        echo "Python version meets the requirements (>= 3.9)."
    else
        echo "Python version is older than 3.9. Updating..."
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt-get update -y
        sudo apt-get install -y python3.10 python3.10-venv python3.10-distutils
        echo "A newer version of Python has been installed."
    fi
else
    echo "Installing Python 3..."
    sudo apt-get install -y python3 python3-pip
    echo "Python 3 successfully installed."
fi

# Ensure pip is installed
if ! command_exists pip3; then
    echo "Installing pip3..."
    sudo apt-get install -y python3-pip
fi

# 4. Install Django
if python3 -c "import django" >/dev/null 2>&1 || command_exists django-admin; then
    echo "Django is already installed: $(python3 -m django --version 2>/dev/null || echo 'unknown version')"
else
    echo "Installing Django via pip..."
    # Install for the current user to avoid conflicts with system packages
    python3 -m pip install --user Django || pip3 install Django || pip3 install Django --break-system-packages
    echo "Django successfully installed."
fi

echo "All tools successfully installed!"
