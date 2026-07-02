#!/bin/bash
# Targeted immediate key-reversing script for KDE Plasma 6 Wayland (Ubuntu 26.04)

echo "[KDE Wayland] Executing hardware-level key remap..."

# 1. Update the configuration keys explicitly with correct formatting rules
kwriteconfig6 --file kxkbrc --group Layout --key ConfigureLayouts "true"
kwriteconfig6 --file kxkbrc --group Layout --key Use "true"
kwriteconfig6 --file kxkbrc --group Layout --key Options "altwin:swap_lalt_lwin"

# 2. Tell the system control module to broadcast the update via the Global DBus engine
dbus-send --session --type=signal --reply-timeout=100 --dest=org.kde.keyboard /Layouts org.kde.keyboard.reloadConfig

# 3. Force KWin\'s internal Input Method and Window Configuration to pick up the updated properties
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure

# 4. Fallback for XWayland window applications (Terminal, VSCode, Electron windows)
if command -v setxkbmap >/dev/null 2>&1; then
    setxkbmap -option altwin:swap_lalt_lwin
fi

zenity --notification --text "KDE Wayland: Alt/Win keys reversed instantly."
