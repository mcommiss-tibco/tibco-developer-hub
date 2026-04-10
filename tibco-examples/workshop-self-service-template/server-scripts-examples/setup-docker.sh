#!/bin/bash

# setup-docker.sh
# Example script for setting up Docker environment for workshop users

set -e

# Environment variables from template
USER_PREFIX=${USER_PREFIX:-workshop}
USER_COUNT=${USER_COUNT:-10}

echo "Setting up Docker environment for workshop users..."

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    
    # Update package index
    apt-get update
    
    # Install required packages
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Start and enable Docker
    systemctl start docker
    systemctl enable docker
    
    echo "Docker installed successfully"
else
    echo "Docker is already installed"
fi

# Ensure docker group exists
if ! getent group docker >/dev/null 2>&1; then
    groupadd docker
fi

# Add workshop users to docker group and setup Docker environment
for ((i=1; i<=USER_COUNT; i++)); do
    username="${USER_PREFIX}$(printf "%02d" $i)"
    
    if id "$username" >/dev/null 2>&1; then
        echo "Setting up Docker for user: $username"
        
        # Add user to docker group
        usermod -aG docker "$username"
        
        # Create docker folder in user's home
        mkdir -p "/home/$username/docker"
        chown "$username:workshop" "/home/$username/docker"
        
        # Create a simple Dockerfile example
        cat > "/home/$username/docker/Dockerfile.example" << EOF
# Example Dockerfile for workshop
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \\
    curl \\
    wget \\
    vim \\
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["bash"]
EOF
        
        # Create docker-compose example
        cat > "/home/$username/docker/docker-compose.yml" << EOF
version: '3.8'

services:
  workshop-app:
    build: .
    container_name: workshop-container
    volumes:
      - ./workspace:/workspace
    stdin_open: true
    tty: true
EOF
        
        chown -R "$username:workshop" "/home/$username/docker"
        
        echo "Docker environment setup completed for $username"
    else
        echo "User $username does not exist, skipping..."
    fi
done

# Pull some common workshop images
echo "Pulling common workshop Docker images..."
docker pull ubuntu:22.04
docker pull node:18
docker pull python:3.11
docker pull nginx:alpine

echo "Docker setup completed for all workshop users!"
echo "Users can now run Docker commands without sudo after logging out and back in."