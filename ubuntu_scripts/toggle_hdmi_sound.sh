#!/bin/bash
# Usually M+i

current_output=$(pacmd list-cards |
                 grep output\: |
                 grep "active" |
                 grep -Po "output:(\w+)")
echo $current_output

if [ "$current_output" = "output:analog" ];
then
    pactl set-card-profile 0 output:hdmi-stereo
    zenity --notification --text "HDMI sound"
else
    pactl set-card-profile 0 output:analog-stereo
    zenity --notification --text "Laptop sound"
fi
