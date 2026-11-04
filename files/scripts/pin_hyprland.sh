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
# The F45 COPR still carries the working 0.56.2-era stack. Pin the whole
# set (Hyprland plus the libraries/apps it was built against), because F45
# otherwise installs newer hyprgraphics/aquamarine/hyprtoolkit builds that
# are ABI-incompatible with 0.56.2.
# These are the F45 equivalents of the RPMs that shipped in the working
# 44.20261028 (08:00) deployment, pulled from the same COPR
# (lionheartp/Hyprland).
# Remove this pin once 0.57.x works again on Gen7 Intel graphics.

BASE="https://download.copr.fedorainfracloud.org/results/lionheartp/Hyprland/fedora-45-x86_64/Packages"

echo "--- Pinning Hyprland to 0.56.2 ---"

rpm-ostree override replace \
    "${BASE}/h/hyprland-0.56.2-3.fc45.x86_64.rpm" \
    "${BASE}/h/hyprland-uwsm-0.56.2-3.fc45.x86_64.rpm" \
    "${BASE}/h/hyprgraphics-0.5.1-3.fc45.x86_64.rpm" \
    "${BASE}/a/aquamarine-0.15.1-1.fc45.x86_64.rpm" \
    "${BASE}/h/hyprtoolkit-0.6.0-1.fc45.x86_64.rpm" \
    "${BASE}/h/hyprlock-0.9.6-1.fc45.x86_64.rpm" \
    "${BASE}/h/hyprpaper-0.8.4-3.fc45.x86_64.rpm" \
    "${BASE}/h/hyprpolkitagent-0.2.0-1.fc45.x86_64.rpm" \
    "${BASE}/x/xdg-desktop-portal-hyprland-1.4.1-1.fc45.x86_64.rpm"

echo "--- Versions after pin ---"
rpm -q hyprland hyprland-uwsm hyprgraphics aquamarine hyprtoolkit \
    hyprlock hyprpaper hyprpolkitagent xdg-desktop-portal-hyprland

for spec in \
    hyprland:0.56.2 \
    hyprgraphics:0.5.1 \
    aquamarine:0.15.1 \
    hyprtoolkit:0.6.0 \
    hyprlock:0.9.6 \
    hyprpaper:0.8.4 \
    hyprpolkitagent:0.2.0 \
    xdg-desktop-portal-hyprland:1.4.1; do
    pkg="${spec%%:*}"
    want="${spec##*:}"
    got="$(rpm -q --qf '%{VERSION}\n' "$pkg")"
    if [[ "$got" != "$want" ]]; then
        echo "CRITICAL: $pkg is $got, expected $want after the override."
        exit 1
    fi
done
