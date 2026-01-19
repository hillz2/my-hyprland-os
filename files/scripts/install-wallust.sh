#!/usr/bin/bash
set -eou pipefail

# Update to a known recent version
WALLUST_VERSION="3.4.0"
echo "Installing Wallust v${WALLUST_VERSION}..."

# Create a temporary directory for clean extraction
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download from Codeberg (Primary repo)
# Using the standard Rust binary release naming convention
wget "https://codeberg.org/explosion-mental/wallust/releases/download/${WALLUST_VERSION}/wallust-${WALLUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" -O wallust.tar.gz

# Extract the archive
tar -xzf wallust.tar.gz

# Find the binary named 'wallust' anywhere in the extracted files and move it
# This prevents errors if the binary is inside a subdirectory (e.g. wallust-v3.4.0/)
find . -type f -name "wallust" -exec mv {} /usr/bin/wallust \;

# Ensure it's executable
chmod +x /usr/bin/wallust

# Cleanup
cd /
rm -rf "$TMP_DIR"
