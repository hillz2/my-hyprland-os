#!/usr/bin/env bash
set -ouex pipefail

# wallust is intentionally PINNED to 3.4.0.
#
# The Hyprland setup (wallust.toml + templates) uses the wallust v3 config
# schema. wallust 4.x changed that schema -- e.g. `backend = "kmeans"` is no
# longer valid (kmeans moved to `palette`), so a v4 binary fails with:
#     unknown variant `kmeans`, expected one of `full`, `resized`, `wal`, ...
# Do NOT go back to "latest" unless the wallust config is migrated to v4 first.
#
# Note: upstream misnamed the 3.4.0 assets as "3.3.0"; this tarball really
# contains wallust 3.4.0 (commit 3f557fe, 2025-07-15).
WALLUST_VERSION="3.4.0"
WALLUST_URL="https://codeberg.org/explosion-mental/wallust/releases/download/${WALLUST_VERSION}/wallust-3.3.0-x86_64-unknown-linux-musl.tar.gz"
WALLUST_SHA256="678311b665dc9561c41d828108e608e959c2d60a241abf5a6e26c56e1f56c5ee"

echo "--- Installing wallust ${WALLUST_VERSION} (pinned) ---"

mkdir -p /tmp/wallust-dl
cd /tmp/wallust-dl

# 1. Download the pinned release asset
curl -fsSL "$WALLUST_URL" -o wallust.tar.gz

# 2. Verify the checksum before installing anything
echo "${WALLUST_SHA256}  wallust.tar.gz" | sha256sum -c -

# 3. Unpack (the release is a .tar.gz containing a static binary)
tar -xzf wallust.tar.gz
BINARY=$(find . -type f -name wallust | head -1)

if [[ -z "$BINARY" ]]; then
    echo "CRITICAL: wallust binary not found in archive."
    exit 1
fi

# 4. Install to system path
install -m 755 "$BINARY" /usr/bin/wallust

echo "Wallust installed successfully:"
wallust --version
