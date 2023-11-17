#/bin/bash
# Usually M+i
if $(gsettings get org.gnome.desktop.notifications show-banners)
then
    gsettings set org.gnome.desktop.notifications show-banners false
    zenity --notification --text "DND 0"
else
    gsettings set org.gnome.desktop.notifications show-banners true
    zenity --notification --text "DND 1"
fi
