#!/bin/bash

# install-workshop-tools.sh
# Example script for installing common workshop tools

set -e

WORKSHOP_NAME=${WORKSHOP_NAME:-"TIBCO Workshop"}

echo "Installing workshop tools for: $WORKSHOP_NAME"

# Update system packages
apt-get update

# Install basic development tools
echo "Installing basic development tools..."
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    jq \
    zip \
    unzip \
    build-essential

# Install Node.js and npm
echo "Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install Python pip and common packages
echo "Installing Python tools..."
apt-get install -y python3 python3-pip
pip3 install --upgrade pip
pip3 install jupyter notebook pandas numpy requests

# Install Java 17
echo "Installing Java 17..."
apt-get install -y openjdk-17-jdk

# Install Maven
echo "Installing Maven..."
apt-get install -y maven

# Install VS Code (code-server for web access)
echo "Installing code-server for web-based VS Code..."
curl -fsSL https://code-server.dev/install.sh | sh

# Create a systemd service template for code-server
cat > /etc/systemd/system/code-server@.service << 'EOF'
[Unit]
Description=code-server for %i
After=network.target

[Service]
Type=exec
User=%i
WorkingDirectory=/home/%i
ExecStart=/usr/bin/code-server --bind-addr 0.0.0.0:8080 --auth password --password workshop2024
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Install TIBCO tools (example - adjust for your specific tools)
echo "Setting up TIBCO tools directory..."
mkdir -p /opt/tibco-tools
cd /opt/tibco-tools

# Download and setup TIBCO CLI (example)
# wget https://example.com/tibco-cli.tar.gz
# tar -xzf tibco-cli.tar.gz
# chmod +x tibco-cli
# ln -s /opt/tibco-tools/tibco-cli /usr/local/bin/tibco

# Create workshop tools info file
cat > /usr/local/bin/workshop-info << 'EOF'
#!/bin/bash
echo "=== Workshop Tools Information ==="
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "Python: $(python3 --version)"
echo "Java: $(java -version 2>&1 | head -n1)"
echo "Maven: $(mvn --version | head -n1)"
echo "Git: $(git --version)"
echo "Docker: $(docker --version 2>/dev/null || echo 'Not installed')"
echo ""
echo "Code Server: Available at http://[server-ip]:8080"
echo "Default password: workshop2024"
echo ""
echo "=== Useful Commands ==="
echo "workshop-info        - Show this information"
echo "code-server --help   - VS Code server help"
echo "jupyter notebook     - Start Jupyter notebook"
echo ""
EOF

chmod +x /usr/local/bin/workshop-info

# Install useful aliases for all users
cat >> /etc/bash.bashrc << 'EOF'

# Workshop aliases
alias ll='ls -la'
alias workshop='cd ~/workshop'
alias tools='workshop-info'
alias serve='python3 -m http.server 8000'

# Git aliases
alias gst='git status'
alias gco='git checkout'
alias gcm='git commit -m'
alias gps='git push'
alias gpl='git pull'

EOF

echo "Workshop tools installation completed!"
echo ""
echo "Installed tools:"
echo "- Node.js $(node --version)"
echo "- Python $(python3 --version)"
echo "- Java $(java -version 2>&1 | head -n1)"
echo "- Git, Maven, VS Code Server, and more"
echo ""
echo "Users can run 'workshop-info' to see available tools and commands"