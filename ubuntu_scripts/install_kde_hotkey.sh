#!/bin/bash

# --- Configuration ---
# 1. Get the absolute path of the folder containing THIS script
BASE_DIR=$(dirname "$(readlink -f "$0")")

# 2. Define script paths relative to the folder
SCRIPT_J="$BASE_DIR/reverse_alt_super_keys.sh"
SCRIPT_H="$BASE_DIR/normal_alt_super_keys.sh"

echo $SCRIPT_J
echo $SCRIPT_H

# Script 1
NAME_J="Run My Custom Keybindings J"
HOTKEY_J="Ctrl+Shift+J"

# Script 2 (or a different function)
NAME_H="Run My Custom Keybindings H"
HOTKEY_H="Ctrl+Shift+H"

# --- Logic ---

# Ensure scripts are executable
chmod +x "$SCRIPT_J"
chmod +x "$SCRIPT_H"

# Determine Tool Version
KWC=$(command -v kwriteconfig5 || command -v kwriteconfig6)

# Function to register shortcut (to keep code clean)
register_kde_shortcut() {
    local name=$1
    local key=$2
    local path=$3

    # Use whatever version of kwriteconfig we found earlier
    $KWC --file kglobalshortcutsrc --group "commands" --key "$name" "$key,none,$name"
    $KWC --file kglobalshortcutsrc --group "command_scripts" --key "$name" "$path"
    
    # RELOAD TRIGGER:
    # Instead of qdbus6, we try the standard qdbus or the universal dbus-send
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel.rebindShortcut "$name"
    else
        dbus-send --type=method_call --dest=org.kde.kglobalaccel \
            /kglobalaccel org.kde.KGlobalAccel.rebindShortcut string:"$name"
    fi
}


# Apply both
register_kde_shortcut "$NAME_J" "$HOTKEY_J" "$SCRIPT_J"
register_kde_shortcut "$NAME_H" "$HOTKEY_H" "$SCRIPT_H"

dbus-send --type=method_call --dest=org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel.allShortcutInfos

echo "Success: Registered J ($HOTKEY_J) and H ($HOTKEY_H)"
