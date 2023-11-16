#/bin/bash
# Cycle through the primary displays
# Add to custom keyboard shortcuts and specify "sh path_to_script/script.sh
xrandr --output $(xrandr | grep -w connected | grep -v -e primary | cut -d ' ' -f1) --primary
