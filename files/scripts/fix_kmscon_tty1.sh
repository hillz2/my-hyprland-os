#!/usr/bin/env bash
# Fedora 45's base image ships kmscon and enables kmsconvt@tty1.service.
# kmscon opens /dev/dri/card1 and takes DRM master, so when Hyprland starts
# from tty1, Aquamarine fails with "Device or resource busy" and Hyprland
# aborts. Fedora 44 used getty@tty1, which is why it worked there.
#
# Keep kmscon available for other VTs (logind's autovt@ still points at
# kmsconvt@), but let getty@tty1 own tty1 so Hyprland can autostart there.
set -euo pipefail

SYSTEMD_DIR=/etc/systemd/system
GETTY_WANTS="$SYSTEMD_DIR/getty.target.wants"
GETTY_UNIT="/usr/lib/systemd/system/getty@.service"

echo "--- Detaching kmscon from tty1 (keeping it for other VTs) ---"

# 1. Remove any kmscon alias symlinks for tty1 from getty.target.wants.
mkdir -p "$GETTY_WANTS"
find "$GETTY_WANTS" -maxdepth 1 -type l -name 'kmsconvt@tty1.service' -print -delete

# 2. Enable getty@tty1 so a login prompt (and the .zprofile autostart) exists.
ln -sfn "$GETTY_UNIT" "$GETTY_WANTS/getty@tty1.service"

# --- Verification -----------------------------------------------------------
rc=0

if [ -e "$GETTY_WANTS/kmsconvt@tty1.service" ] || [ -L "$GETTY_WANTS/kmsconvt@tty1.service" ]; then
    echo "ERROR: kmsconvt@tty1.service is still wanted by getty.target"
    rc=1
fi

if [ "$(readlink "$GETTY_WANTS/getty@tty1.service" 2>/dev/null || true)" != "$GETTY_UNIT" ]; then
    echo "ERROR: getty@tty1.service is not enabled"
    rc=1
fi

# Harmless if it points at getty@ instead: tty1 still works, other VTs just
# get a plain getty. Report it so we notice if the base image changes.
if [ "$(readlink "$SYSTEMD_DIR/autovt@.service" 2>/dev/null || true)" = "/usr/lib/systemd/system/kmsconvt@.service" ]; then
    echo "OK: autovt@ points at kmsconvt@ (kmscon remains available on other VTs)"
else
    echo "NOTE: autovt@ does not point at kmsconvt@; other VTs will use getty"
fi

if [ "$rc" -ne 0 ]; then
    echo "CRITICAL: kmscon still owns tty1; Hyprland would fail to start."
    exit 1
fi

echo "OK: getty@tty1 owns tty1; Hyprland can start there"
