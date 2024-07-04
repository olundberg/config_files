#!/bin/bash 
# Reverse the ALT and SUPER KEY
# Reverse this with normal_alt_super_leys.sh
# Usually Ctrl+Shift+H

# Only works on X
# setxkbmap -option altwin:swap_lalt_lwin

# For Wayland use this instead
dconf write /org/gnome/desktop/input-sources/xkb-options "['altwin:swap_lalt_lwin']"

#xmodmap -e "keycode 35 = backslash"
zenity --notification --text "Reverse alt+win"
