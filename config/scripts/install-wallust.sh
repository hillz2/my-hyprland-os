#!/usr/bin/bash
set -eou pipefail

echo "Installing Wallust..."

# Fetch the latest release tag
WALLUST_VERSION=$(curl -s "https://api.github.com/repos/wallust/wallust/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Download the generic linux tarball
wget "https://github.com/wallust/wallust/releases/download/${WALLUST_VERSION}/wallust-${WALLUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" -O wallust.tar.gz

# Extract and move binary
tar -xzf wallust.tar.gz
mv wallust /usr/bin/wallust
chmod +x /usr/bin/wallust

# Cleanup
rm wallust.tar.gz
echo "Wallust installed successfully!"
