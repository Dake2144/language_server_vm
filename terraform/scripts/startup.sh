#!/bin/bash
# =============================================================================
# VM Startup Script - Docker Installation & Configuration
# =============================================================================

set -e

LOG_FILE="/var/log/startup-script.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "Starting VM initialization: $(date)"
echo "=========================================="

# Update system packages
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install essential packages
echo "Installing essential packages..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    htop \
    vim \
    wget \
    unzip \
    jq

# Check if Docker is already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    
    # Add Docker's official GPG key
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    # Set up the Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker Engine
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Enable and start Docker
    systemctl enable docker
    systemctl start docker

    echo "Docker installed successfully!"
else
    echo "Docker is already installed."
fi

# Create docker group and add users (if not exists)
if ! getent group docker > /dev/null; then
    groupadd docker
fi

# Add all users with UID >= 1000 to docker group (regular users)
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    usermod -aG docker "$user" 2>/dev/null || true
    echo "Added $user to docker group"
done

# Create application directories
echo "Creating application directories..."
mkdir -p /opt/app
mkdir -p /opt/app/data
mkdir -p /opt/app/logs
mkdir -p /opt/app/backups

# Set permissions
chmod 755 /opt/app
chmod 755 /opt/app/data
chmod 755 /opt/app/logs
chmod 755 /opt/app/backups

# Configure Docker daemon (optional optimizations)
cat > /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart Docker to apply configuration
systemctl restart docker

# Install Docker Compose standalone (for compatibility)
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose standalone..."
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
    curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Print versions
echo "=========================================="
echo "Installation Summary:"
echo "=========================================="
docker --version
docker compose version
echo "=========================================="
echo "VM initialization completed: $(date)"
echo "=========================================="
