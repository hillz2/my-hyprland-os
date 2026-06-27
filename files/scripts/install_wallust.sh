#!/usr/bin/env bash
set -ouex pipefail

echo "--- Fetching latest Wallust release from Codeberg ---"

# 1. Query Codeberg (Forgejo) API for the release manifest
API_RESPONSE=$(curl -sSL "https://codeberg.org/api/v1/repos/explosion-mental/wallust/releases")

# 2. Extract every matching x86_64 Linux asset URL into RAM
ALL_URLS=$(echo "$API_RESPONSE" | grep -oP '"browser_download_url":\s*"\K[^"]*x86_64[^"]*(linux|musl)[^"]*')

# 3. Grab strictly the newest URL (Zero subshells, immune to SIGPIPE crashes)
read -r DL_URL <<< "$ALL_URLS"

if [[ -z "$DL_URL" ]]; then
    echo "CRITICAL: Failed to resolve Wallust download URL from Codeberg API."
    exit 1
fi

echo "Resolved Codeberg Asset: $DL_URL"

mkdir -p /tmp/wallust-dl
cd /tmp/wallust-dl

# 4. Download the payload
curl -sSL "$DL_URL" -o wallust_payload

# 5. Universal Unpacker: Safely handles .tar.gz, .zip, or raw bare binaries
if tar -xzf wallust_payload 2>/dev/null; then
    BINARY=$(find . -type f -name wallust)
elif unzip -q wallust_payload 2>/dev/null; then
    BINARY=$(find . -type f -name wallust)
else
    BINARY="wallust_payload"
fi

# 6. Install to system path
install -m 755 "$BINARY" /usr/bin/wallust

echo "Wallust installed successfully:"
wallust --version
