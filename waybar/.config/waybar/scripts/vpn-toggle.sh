#!/bin/bash

iface=$(ip -brief link show type wireguard 2>/dev/null | awk '{print $1; exit}')

if [ -n "$iface" ]; then
    sudo -n wg-quick down "$iface" &>/dev/null
else
    choice=$(sudo -n find /etc/wireguard -maxdepth 1 -name '*.conf' -printf '%f\n' 2>/dev/null \
        | sed 's/\.conf$//' \
        | sort \
        | fuzzel -d -p "" --hide-prompt -w 20 --lines 3 --anchor top-right --x-margin 20 --y-margin 10 --keyboard-focus on-demand)
    [ -n "$choice" ] && sudo -n wg-quick up "$choice" &>/dev/null
fi

pkill -RTMIN+9 waybar
