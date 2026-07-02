#!/bin/bash

# Find the battery path via UPower
BAT_PATH=$(upower -e | grep battery | head -n 1)

if [ -z "$BAT_PATH" ]; then
    notify-send "Battery Error" "No battery found via UPower." -u critical
    exit 1
fi

# Get the battery state and energy rate
STATE=$(upower -i "$BAT_PATH" | grep "state:" | awk '{print $2}')
ENERGY_RATE=$(upower -i "$BAT_PATH" | grep "energy-rate:" | awk '{print $2}')

if [ "$STATE" = "charging" ]; then
    # Get time to full
    TIME_TO_FULL=$(upower -i "$BAT_PATH" | grep "time to full:" | cut -d':' -f2- | sed 's/^[ \t]*//')
    [ -z "$TIME_TO_FULL" ] && TIME_TEXT="Calculating..." || TIME_TEXT="$TIME_TO_FULL"
    
    notify-send "Battery Charging" "Speed: **${ENERGY_RATE}W**\nTime until full: **$TIME_TEXT**" -i battery-charging

elif [ "$STATE" = "discharging" ]; then
    # Get time to empty
    TIME_TO_EMPTY=$(upower -i "$BAT_PATH" | grep "time to empty:" | cut -d':' -f2- | sed 's/^[ \t]*//')
    [ -z "$TIME_TO_EMPTY" ] && TIME_TEXT="Calculating..." || TIME_TEXT="$TIME_TO_EMPTY"
    
    notify-send "Battery Discharging" "Discharge rate: **${ENERGY_RATE}W**\nTime remaining: **$TIME_TEXT**" -i battery-caution

else
    # Handles states like "fully-charged" or "unknown"
    PERCENT=$(upower -i "$BAT_PATH" | grep "percentage:" | awk '{print $2}')
    notify-send "Battery Status" "Status: **$STATE** ($PERCENT)" -i battery
fi
