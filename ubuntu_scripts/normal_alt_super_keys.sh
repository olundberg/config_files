#!/bin/bash 
# Set the normal keys back again
# To undo reverse_als_super_keys.sh
# Usually Ctrl+Shift+J

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # For Wayland use this instead
    # 1. Write the keyboard option you want
    dconf write /org/gnome/desktop/input-sources/xkb-options "['altwin:altwin']"
    # 2. Cache your current active language layout list
    VAL=$(gsettings get org.gnome.desktop.input-sources sources)
    # 3. Change it to an empty list (forces a momentary drop/reset of input handling)
    gsettings set org.gnome.desktop.input-sources sources "[]"
    # 4. Put your original layout back instantly
    gsettings set org.gnome.desktop.input-sources sources "$VAL"
    # Print notificatoin
    zenity --notification --text "Normal alt+win (Wayland)"
elif [ "$XDG_SESSION_TYPE" = "x11" ]; then
    # Only works on X
    setxkbmap -option altwin:altwin
    zenity --notification --text "Normal alt+win (X11)"
else
    echo "Could not detect session type (Environment: $XDG_SESSION_TYPE)"
fi

#xmodmap -e "keycode 35 = backslash"
#zenity --notification --text "Normal alt+win"
