#!/usr/bin/env bash

set -oue pipefail

echo 'Enabling solopasha/hyprland COPR...'
dnf install -y dnf-plugins-core
dnf copr enable -y solopasha/hyprland
dnf copr enable -y tofik/nwg-shell
dnf copr enable -y peterwu/rendezvous
