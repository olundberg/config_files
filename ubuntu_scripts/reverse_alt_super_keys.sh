#!/bin/bash 
# Reverse the ALT and SUPER KEY
# Reverse this with normal_alt_super_leys.sh
# Usually Ctrl+Shift+H
#export DISPLAY=:0

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # For Wayland use this instead
    dconf write /org/gnome/desktop/input-sources/xkb-options "['altwin:swap_lalt_lwin']"
    zenity --notification --text "Reverse alt+win (Wayland)"
elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
    # Only works on X
    setxkbmap -option altwin:swap_lalt_lwin
    zenity --notification --text "Reverse alt+win (X11)"
else
    echo "Could not detect session type (Environment: $XDG_SESSION_TYPE)"
fi

#xmodmap -e "keycode 35 = backslash"
