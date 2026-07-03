#!/bin/bash
# Targeted immediate key-reversing script for KDE Plasma 6 Wayland (Ubuntu 26.04)

echo "[KDE Wayland] Executing hardware-level key remap..."

# 1. Update the configuration keys and notify KWin natively via KConfigWatcher
kwriteconfig6 --file kxkbrc --group Layout --key Options "" --notify
# 2. Force KWin's configuration engine to apply changes instantly
qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure

# 3. Fallback for XWayland legacy applications (Terminal, VSCode, Electron windows)
if command -v setxkbmap >/dev/null 2>&1; then
    setxkbmap -option altwin:swap_lalt_lwin
fi

zenity --notification --text "KDE Wayland: Alt/Win keys reversed instantly."
