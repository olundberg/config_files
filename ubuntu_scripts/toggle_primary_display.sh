#/bin/bash
# Usuallt M+o hotkey "sh /path/.."
xrandr --output $(xrandr | grep -w connected | grep -v -e primary | cut -d ' ' -f1) --primary 
#DISPLAY=:0 /usr/bin/notify-send "Changed primary display"
zenity --notification --text "Changed primary display"
