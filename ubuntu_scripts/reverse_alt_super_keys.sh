#!/bin/bash 
# Usually Ctrl+Shift+H

setxkbmap -option altwin:swap_lalt_lwin
xmodmap -e "keycode 35 = backslash"
zenity --notification --text "Reverse alt+win, bind pipe to backslash"
