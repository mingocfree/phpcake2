#!/bin/bash

# 1. Determine the correct User to add to the group
# If run with sudo, SUDO_USER holds the original username.
TARGET_USER=${SUDO_USER:-$(whoami)}
echo "Target user identified as: $TARGET_USER"

# 2. Add the correct user to the docker group
echo "Adding $TARGET_USER to docker group..."
sudo usermod -aG docker $TARGET_USER

# 3. Set up Architecture variables (Buildx and Compose name things differently)
OS=$(uname -s | tr '[:upper:]' '[:lower:]') # linux
ARCH=$(uname -m)                            # x86_64 or aarch64

# Buildx uses 'amd64', Compose uses 'x86_64'
if [ "$ARCH" == "x86_64" ]; then
    BUILDX_ARCH="amd64"
    COMPOSE_ARCH="x86_64"
elif [ "$ARCH" == "aarch64" ]; then
    BUILDX_ARCH="arm64"
    COMPOSE_ARCH="aarch64"
else
    BUILDX_ARCH=$ARCH
    COMPOSE_ARCH=$ARCH
fi

DIR="/usr/local/lib/docker/cli-plugins"
sudo mkdir -p $DIR

# 4. Install Docker Compose (Force Overwrite to ensure correctness)
# We use curl -f to fail silently if the link is wrong, preventing corrupt files
echo "Installing Docker Compose Plugin..."
COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
COMPOSE_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-${OS}-${COMPOSE_ARCH}"

echo "Downloading Compose ${COMPOSE_VERSION}..."
sudo curl -L -f "$COMPOSE_URL" -o $DIR/docker-compose
sudo chmod +x $DIR/docker-compose

# 5. Install Docker Buildx (Fixed Syntax and Arch)
echo "Installing Docker Buildx Plugin..."
BUILDX_VERSION=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | grep 'tag_name' | cut -d\" -f4)
# Note: Buildx binaries format is usually 'buildx-v0.12.0.linux-amd64'
BUILDX_URL="https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.${OS}-${BUILDX_ARCH}"

echo "Downloading Buildx ${BUILDX_VERSION}..."
sudo curl -L -f "$BUILDX_URL" -o $DIR/docker-buildx
sudo chmod +x $DIR/docker-buildx

# 6. Verify
echo "----------------------------------------------------------------"
echo "Verifying versions..."
docker compose version
docker buildx version

echo "----------------------------------------------------------------"
echo "Setup complete for user: $TARGET_USER"
echo "Run 'newgrp docker' to apply group changes immediately."
