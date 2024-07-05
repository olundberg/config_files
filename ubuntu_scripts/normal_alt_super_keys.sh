#!/bin/bash 
# Set the normal keys back again
# To undo reverse_als_super_keys.sh
# Usually Ctrl+Shift+J

# Only works with X
# setxkbmap -option # altwin:altwin

# Use this if on Gnome (Wayland)
dconf write /org/gnome/desktop/input-sources/xkb-options "['altwin:altwin']"

#xmodmap -e "keycode 35 = backslash"
zenity --notification --text "Normal alt+win"
