#!/bin/bash 
# Set the normal keys back again
# To undo reverse_als_super_keys.sh
# Usually Ctrl+Shift+J

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # For Wayland use this instead
    dconf write /org/gnome/desktop/input-sources/xkb-options "['altwin:altwin']"
elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
    # Only works on X
    setxkbmap -option # altwin:altwin
else
    echo "Could not detect session type (Environment: $XDG_SESSION_TYPE)"
fi

#xmodmap -e "keycode 35 = backslash"
zenity --notification --text "Normal alt+win"
