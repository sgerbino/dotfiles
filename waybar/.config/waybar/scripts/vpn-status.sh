#!/bin/bash

iface=$(ip -brief link show type wireguard 2>/dev/null | awk '{print $1; exit}')

if [ -n "$iface" ]; then
    echo "{\"text\": \"󰌾  $iface\", \"tooltip\": \"VPN active: $iface\", \"class\": \"active\"}"
else
    echo "{\"text\": \"󰌿\", \"tooltip\": \"VPN disconnected\", \"class\": \"inactive\"}"
fi
