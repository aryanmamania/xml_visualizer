#!/bin/bash

set -e

echo "🚀 Starting Route Visualizer Setup..."

IMAGE_NAME="aryanmamania17/route-visualizer10:latest"
CONTAINER_NAME="route-visualizer"
HOST_PORT=8001

WORKDIR="$HOME/route-visualizer"
#mkdir -p "$WORKDIR"/{input,processed,visualizer}
mkdir -p "$WORKDIR"/input
cd "$WORKDIR"

if [ ! -f data.cfg ]; then
  echo "env: dev" > data.cfg
fi

echo "📁 Directory structure created at $WORKDIR"

# 🐋 Install Docker if missing
if ! command -v docker &> /dev/null; then
  echo "🐋 Docker not found. Installing Docker..."

  if [ -f /etc/debian_version ]; then
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
  else
    echo "❌ Docker install not supported on this OS. Please install manually."
    exit 1
  fi
else
  echo "✅ Docker is already installed."
fi

# 🔧 Git check (non-fatal if fails)
if ! command -v git &> /dev/null; then
  echo "📦 Git not found. Skipping Git repo sync."
  GIT_AVAILABLE=false
else
  echo "✅ Git is available."
  GIT_AVAILABLE=true
fi

# 🐳 Pull and run the container
echo "📦 Pulling image: $IMAGE_NAME"
sudo docker pull "$IMAGE_NAME"

if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "🧹 Removing old container..."
sudo docker rm -f "$CONTAINER_NAME"
fi

echo "🚀 Running container '$CONTAINER_NAME' on http://localhost:$HOST_PORT"

sudo docker run -d --name "$CONTAINER_NAME" \
  -p "$HOST_PORT:8001" \
  -v "$WORKDIR/input:/app/input" \
  -v "$WORKDIR/data.cfg:/app/data.cfg" \
  "$IMAGE_NAME"

# ⚙️ Initial render
echo "⚙️ Running initial render..."
sudo docker exec "$CONTAINER_NAME" /app/venv/bin/python3 /app/render_routes.py

# 🌐 Clone Git repo (optional)
REPO_URL="http://135.181.138.54:3080/admin/xml_files.git"
TEMP_CLONE_DIR="$WORKDIR/tmp_git_repo"

if [ "$GIT_AVAILABLE" = true ]; then
  echo "🌐 Attempting to fetch XMLs from Git repo..."
  rm -rf "$TEMP_CLONE_DIR"

  if git clone "$REPO_URL" "$TEMP_CLONE_DIR"; then
    echo "✅ GitLab repo cloned to $TEMP_CLONE_DIR"

    shopt -s nullglob
    for xml in "$TEMP_CLONE_DIR"/*.xml; do
      fname=$(basename "$xml")
      dest="$WORKDIR/input/$fname"
      if [ -f "$dest" ]; then
        echo "⚠️ Skipping duplicate: $fname"
      else
        echo "⬇️ Copying: $fname"
        sudo cp "$xml" "$dest"
      fi
    done
    shopt -u nullglob

    rm -rf "$TEMP_CLONE_DIR"
    
    echo "🔄 Re-rendering with Git XMLs..."
    docker exec "$CONTAINER_NAME" /app/venv/bin/python3 /app/render_routes.py
  else
    echo "⚠️ Git clone failed: $REPO_URL"
    echo "🟡 Skipping Git XML import. You can still add XMLs to $WORKDIR/input manually."
  fi
else
  echo "ℹ️ Skipping Git repo cloning (Git not installed)."
fi

# ✅ Done
echo "✅ Setup complete!"
echo "📂 XML files directory: $WORKDIR/input"
echo "🌐 Access the visualizer at: http://localhost:$HOST_PORT/visualizer/index.html"
echo "🔒 Login: admin / admin"
