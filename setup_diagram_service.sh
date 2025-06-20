#!/bin/bash

set -e

# Variables
IMAGE_NAME="aryanmamania17/diagram2:latest"
CONTAINER_PORT=80
HOST_PORT=9003
INPUT_DIR="$(pwd)/input"

# Function: Install Docker if not already installed
install_docker() {
    echo "[INFO] Docker not found. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io

    echo "[INFO] Docker installed successfully!"
    sudo usermod -aG docker "$USER"
    echo "[INFO] Added $USER to docker group. You may need to log out and back in."
}

# Step 1: Check Docker installation
if ! command -v docker &> /dev/null; then
    install_docker
else
    echo "[INFO] Docker is already installed."
fi

# Step 2: Create input directory with proper permissions
echo "[INFO] Creating input directory at $INPUT_DIR"
mkdir -p "$INPUT_DIR"
chmod 777 "$INPUT_DIR"

# Step 3: Pull Docker image
echo "[INFO] Pulling Docker image: $IMAGE_NAME"
docker pull "$IMAGE_NAME"

# Step 4: Run Docker container
echo "[INFO] Running Docker container on port $HOST_PORT"
docker run -d -p ${HOST_PORT}:${CONTAINER_PORT} -v "$INPUT_DIR":/app/input "$IMAGE_NAME"

echo "[SUCCESS] Container is running on http://localhost:${HOST_PORT}"
