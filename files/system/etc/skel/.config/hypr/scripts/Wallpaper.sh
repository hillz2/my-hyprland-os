#!/usr/bin/env bash

# 1. Boot the daemon
hyprpaper &
sleep 0.5

# 2. Preload the image using the OS's real $HOME
IMG="$HOME/.config/hypr/wallpaper.png"
hyprctl hyprpaper preload "$IMG"

# 3. Ask Hyprland for the name of every active monitor, and apply to all of them
for mon in $(hyprctl monitors | grep -oP 'Monitor \K[^\s]+'); do
    hyprctl hyprpaper wallpaper "$mon,$IMG"
done
