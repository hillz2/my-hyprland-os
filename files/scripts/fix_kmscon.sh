#!/usr/bin/env bash
# Fedora 45's base image ships kmscon and enables kmsconvt@tty1.service.
# kmscon opens /dev/dri/card1 and takes DRM master, so when Hyprland starts
# from tty1, Aquamarine fails with "Device or resource busy" and Hyprland
# aborts. Fedora 44 used getty@tty1, which is why it worked there.
#
# Restore the F44 arrangement: getty@tty1 owns tty1, kmscon cannot start,
# and logind uses getty@ (not kmsconvt@) for newly opened VTs.
set -euo pipefail

SYSTEMD_DIR=/etc/systemd/system
GETTY_WANTS="$SYSTEMD_DIR/getty.target.wants"
KMSCON_UNIT="kmsconvt@.service"
GETTY_UNIT="/usr/lib/systemd/system/getty@.service"

echo "--- Ensuring kmscon never owns a VT ---"

# 1. Remove any kmscon alias symlinks from getty.target.wants.
mkdir -p "$GETTY_WANTS"
find "$GETTY_WANTS" -maxdepth 1 -type l -name 'kmsconvt@*.service' -print -delete

# 2. Enable getty@tty1 so a login prompt (and the .zprofile autostart) exists.
ln -sfn "$GETTY_UNIT" "$GETTY_WANTS/getty@tty1.service"

# 3. Mask kmsconvt@.service so nothing can start kmscon on any VT.
ln -sfn /dev/null "$SYSTEMD_DIR/$KMSCON_UNIT"

# 4. F45 points autovt@.service at kmsconvt@.service. Repoint it at getty so
#    VTs opened later (Ctrl+Alt+F2, ...) still get a usable login prompt.
ln -sfn "$GETTY_UNIT" "$SYSTEMD_DIR/autovt@.service"

# --- Verification -----------------------------------------------------------
rc=0

if [ -e "$GETTY_WANTS/kmsconvt@tty1.service" ] || [ -L "$GETTY_WANTS/kmsconvt@tty1.service" ]; then
    echo "ERROR: kmsconvt@tty1.service is still wanted by getty.target"
    rc=1
fi

if [ "$(readlink "$SYSTEMD_DIR/$KMSCON_UNIT" 2>/dev/null || true)" != "/dev/null" ]; then
    echo "ERROR: $KMSCON_UNIT is not masked"
    rc=1
fi

if [ "$(readlink "$GETTY_WANTS/getty@tty1.service" 2>/dev/null || true)" != "$GETTY_UNIT" ]; then
    echo "ERROR: getty@tty1.service is not enabled"
    rc=1
fi

if [ "$(readlink "$SYSTEMD_DIR/autovt@.service" 2>/dev/null || true)" != "$GETTY_UNIT" ]; then
    echo "ERROR: autovt@.service does not point at getty@.service"
    rc=1
fi

if [ "$rc" -ne 0 ]; then
    echo "CRITICAL: kmscon/tty1 setup is wrong; Hyprland would fail to start."
    exit 1
fi

echo "OK: getty@tty1 owns tty1 and kmscon is masked"
