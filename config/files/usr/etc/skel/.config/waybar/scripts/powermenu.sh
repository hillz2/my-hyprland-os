#!/bin/bash

# Options
shutdown="⏻ Shutdown"
reboot="🔄 Reboot"
lock="🔒 Lock"
logout="🚪 Logout"

# Rofi Command
options="$lock\n$logout\n$reboot\n$shutdown"
chosen="$(echo -e "$options" | rofi -dmenu -i -p "Power Menu")"

# Actions
case $chosen in
    $shutdown)
        systemctl poweroff
        ;;
    $reboot)
        systemctl reboot
        ;;
    $lock)
        # Replace 'hyprlock' with your locker (swaylock, gtklock, etc.)
        pidof hyprlock || hyprlock
        ;;
    $logout)
        hyprctl dispatch exit
        ;;
esac
