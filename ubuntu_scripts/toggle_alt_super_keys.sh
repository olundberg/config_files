#!/bin/bash 
# Usually Super+Shift+H

current_output=$(setxkbmap -query | grep option)

if [ "$current_output" = "" ];
then
    setxkbmap -option altwin:swap_lalt_lwin
    zenity --notification --text "Reverse layout"
else
    setxkbmap -option
    zenity --notification --text "Normal layout"
fi
