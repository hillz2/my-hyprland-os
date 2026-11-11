#!/usr/bin/env bash
set -euo pipefail

# Installs the official Ookla Speedtest CLI from https://www.speedtest.net/apps/cli
#
# We use the upstream static tarball instead of Fedora's `speedtest-cli`
# package: that package is the unofficial Python client, which is unmaintained
# and conflicts with the official `speedtest` binary.
SPEEDTEST_VERSION="1.2.0"

case "$(uname -m)" in
    x86_64)
        SPEEDTEST_ARCH="x86_64"
        SPEEDTEST_SHA256="5690596c54ff9bed63fa3732f818a05dbc2db19ad36ed68f21ca5f64d5cfeeb7"
        ;;
    aarch64)
        SPEEDTEST_ARCH="aarch64"
        SPEEDTEST_SHA256="3953d231da3783e2bf8904b6dd72767c5c6e533e163d3742fd0437affa431bd3"
        ;;
    i686 | i386)
        SPEEDTEST_ARCH="i386"
        SPEEDTEST_SHA256="9ff7e18dbae7ee0e03c66108445a2fb6ceea6c86f66482e1392f55881b772fe8"
        ;;
    armv7hl | armv7l)
        SPEEDTEST_ARCH="armhf"
        SPEEDTEST_SHA256="e45fcdebbd8a185553535533dd032d6b10bc8c64eee4139b1147b9c09835d08d"
        ;;
    *)
        echo "CRITICAL: unsupported architecture: $(uname -m)"
        exit 1
        ;;
esac

SPEEDTEST_URL="https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-${SPEEDTEST_ARCH}.tgz"

echo "--- Installing Ookla Speedtest CLI ${SPEEDTEST_VERSION} (${SPEEDTEST_ARCH}) ---"

# 1. Remove the unofficial Python client if the base image ever ships it.
if rpm -q speedtest-cli >/dev/null 2>&1; then
    echo "Removing conflicting speedtest-cli package"
    dnf remove -y speedtest-cli
fi

if [[ -e /usr/bin/speedtest-cli ]]; then
    echo "Removing leftover /usr/bin/speedtest-cli"
    rm -f /usr/bin/speedtest-cli
fi

# 2. Download the pinned release asset
mkdir -p /tmp/speedtest-dl
cd /tmp/speedtest-dl
curl -fsSL "$SPEEDTEST_URL" -o speedtest.tgz

# 3. Verify the checksum before installing anything
echo "${SPEEDTEST_SHA256}  speedtest.tgz" | sha256sum -c -

# 4. Unpack and install
tar -xzf speedtest.tgz

install -m 755 speedtest /usr/bin/speedtest
install -D -m 644 speedtest.5 /usr/share/man/man5/speedtest.5
install -D -m 644 speedtest.md /usr/share/doc/speedtest/speedtest.md

echo "Speedtest CLI installed successfully:"
speedtest --version
