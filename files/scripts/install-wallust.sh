#!/usr/bin/bash
set -eou pipefail

WALLUST_VERSION="3.4.0"
echo "Installing Wallust v${WALLUST_VERSION}..."

# Create temp dir
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download from Codeberg (Fixed URL with 'v' prefix)
wget "https://codeberg.org/explosion-mental/wallust/releases/download/v${WALLUST_VERSION}/wallust-${WALLUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" -O wallust.tar.gz

# Extract
tar -xzf wallust.tar.gz

# Find and move the binary (handles any folder structure inside the tar)
find . -type f -name "wallust" -exec mv {} /usr/bin/wallust \;
chmod +x /usr/bin/wallust

# Cleanup
cd /
rm -rf "$TMP_DIR"
