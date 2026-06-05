#!/bin/bash 
# Reverse the ALT and SUPER KEY
# Reverse this with normal_alt_super_leys.sh
# Usually Ctrl+Shift+H
#export DISPLAY=:0

# NOTE, if it doesnt take effect, logout and in might do,
# ASK Gemini how to make it take effect immediately instead

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # For Wayland use this instead
    dconf write /org/gnome/desktop/input-sources/xkb-options "['altwin:swap_lalt_lwin']"

    VAL=$(gsettings get org.gnome.desktop.input-sources sources)
    # 3. Change it to an empty list (forces a momentary drop/reset of input handling)
    gsettings set org.gnome.desktop.input-sources sources "[]"
    # 4. Put your original layout back instantly
    gsettings set org.gnome.desktop.input-sources sources "$VAL"
    # Print notificatoin

    zenity --notification --text "Reverse alt+win (Wayland)"
elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
    # Only works on X
    setxkbmap -option altwin:swap_lalt_lwin
    zenity --notification --text "Reverse alt+win (X11)"
else
    echo "Could not detect session type (Environment: $XDG_SESSION_TYPE)"
fi

#xmodmap -e "keycode 35 = backslash"
