#/bin/bash
rfkill unblock bluetooth
DISPLAY=:0 /usr/bin/notify-send "Turned on bluetooth"
#zenity --notification --text "Test"
