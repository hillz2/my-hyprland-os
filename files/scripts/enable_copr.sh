#!/usr/bin/env bash

set -oue pipefail

echo 'Enabling solopasha/hyprland COPR...'
dnf install -y dnf-plugins-core
dnf copr enable -y solopasha/hyprland
