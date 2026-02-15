#!/bin/bash
# =============================================================================
# VM Setup Script - Run on Target VM after SSH connection
# Usage: curl -sSL <url> | bash  OR  ./setup-vm.sh
# =============================================================================

set -e

echo "=============================================="
echo "  Talant Center - VM Setup Script"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    print_warning "Running without root privileges. Will use sudo where needed."
    SUDO="sudo"
else
    SUDO=""
fi

# Step 1: Update system
echo ""
echo "Step 1: Updating system packages..."
$SUDO apt update
$SUDO apt upgrade -y
print_status "System updated"

# Step 2: Install prerequisites
echo ""
echo "Step 2: Installing prerequisites..."
$SUDO apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    htop \
    vim \
    wget \
    unzip
print_status "Prerequisites installed"

# Step 3: Install Docker
echo ""
echo "Step 3: Installing Docker..."
if command -v docker &> /dev/null; then
    print_warning "Docker is already installed"
    docker --version
else
    # Add Docker's official GPG key
    $SUDO install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | $SUDO gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    $SUDO chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      $SUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

    # Install Docker
    $SUDO apt update
    $SUDO apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    print_status "Docker installed"
fi

# Step 4: Configure Docker
echo ""
echo "Step 4: Configuring Docker..."

# Enable Docker service
$SUDO systemctl enable docker
$SUDO systemctl start docker

# Add current user to docker group
$SUDO usermod -aG docker $USER
print_status "Added $USER to docker group"

# Configure Docker daemon
$SUDO tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

$SUDO systemctl restart docker
print_status "Docker configured"

# Step 5: Create application directories
echo ""
echo "Step 5: Creating application directories..."
$SUDO mkdir -p /opt/app/{data,logs,backups,configs}
$SUDO chown -R $USER:$USER /opt/app
chmod 755 /opt/app
print_status "Application directories created at /opt/app"

# Step 6: Install additional tools
echo ""
echo "Step 6: Installing additional tools..."

# Install lazydocker (optional - TUI for Docker)
if ! command -v lazydocker &> /dev/null; then
    curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash 2>/dev/null || true
fi

print_status "Additional tools installed"

# Summary
echo ""
echo "=============================================="
echo "  Setup Complete!"
echo "=============================================="
echo ""
echo "Docker version:"
docker --version
echo ""
echo "Docker Compose version:"
docker compose version
echo ""
echo -e "${YELLOW}IMPORTANT:${NC} Log out and back in for docker group changes to take effect!"
echo ""
echo "Quick commands:"
echo "  - Check Docker: docker ps"
echo "  - App directory: cd /opt/app"
echo "  - View logs: docker logs <container>"
echo ""
echo "Next steps:"
echo "  1. Log out: exit"
echo "  2. SSH back in"
echo "  3. Verify: docker ps"
echo ""
