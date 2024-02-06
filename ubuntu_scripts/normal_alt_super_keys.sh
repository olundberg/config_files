#!/bin/bash 
# Usually Ctrl+Shift+J

setxkbmap -option # altwin:altwin
#xmodmap -e "keycode 35 = backslash"
zenity --notification --text "Normal alt+win, bind pipe to backslash"
