#!/usr/bin/env bash
set -oue pipefail

# Hyprland is intentionally PINNED to 0.56.2.
#
# Hyprland 0.57.0 breaks OpenGL clients on this machine (Intel Ivy Bridge
# HD 2500 / i915 with Mesa 26.2.3):
#   * kitty cannot find an EGL config on the Wayland path:
#       "EGL: No EGLConfigs returned"
#       "kitty requires working OpenGL 3.1 drivers"
#   * forcing kitty onto XWayland (kitty's linux_display_server = x11) makes
#     translucent windows render with a corrupted buffer (sliced / striped
#     text) instead of glyphs.
# Hyprland's own startup log shows the same class of failure:
#   "[EGL] Command eglCreateContext errored out with EGL_BAD_MATCH"
# The previous 0.56.2 builds render correctly on both paths.
#
# These are the exact RPMs that shipped in the working 44.20261028 (08:00)
# deployment, pulled from the same COPR (lionheartp/Hyprland).
# Remove this pin once 0.57.x works again on Gen7 Intel graphics.

BASE="https://download.copr.fedorainfracloud.org/results/lionheartp/Hyprland/fedora-44-x86_64"

echo "--- Pinning Hyprland to 0.56.2 ---"

rpm-ostree override replace \
    "${BASE}/10966333-hyprland/hyprland-0.56.2-3.fc44.x86_64.rpm" \
    "${BASE}/10966333-hyprland/hyprland-uwsm-0.56.2-3.fc44.x86_64.rpm" \
    "${BASE}/10791543-xdg-desktop-portal-hyprland/xdg-desktop-portal-hyprland-1.4.1-1.fc44.x86_64.rpm"

echo "--- Versions after pin ---"
rpm -q hyprland hyprland-uwsm xdg-desktop-portal-hyprland

if ! rpm -q --qf '%{VERSION}\n' hyprland | grep -qx '0.56.2'; then
    echo "CRITICAL: hyprland is not 0.56.2 after the override."
    exit 1
fi
