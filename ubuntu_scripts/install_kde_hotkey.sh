#!/bin/bash

# --- Configuration ---
# 1. Get the absolute path of the folder containing THIS script
BASE_DIR=$(dirname "$(readlink -f "$0")")

# 2. Define script paths relative to the folder
SCRIPT_J="$BASE_DIR/reverse_alt_super_keys.sh"
SCRIPT_H="$BASE_DIR/normal_alt_super_keys.sh"

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

# Function to register shortcut (to keep code clean)
register_kde_shortcut() {
    local name=$1
    local key=$2
    local path=$3

    # 1. Detect which kwriteconfig version is available (update to 6?)
    KWC="kwriteconfig5"

    # 2. Write the configuration
    $KWC --file kglobalshortcutsrc --group "commands" --key "$name" "$key,none,$name"
    $KWC --file kglobalshortcutsrc --group "command_scripts" --key "$name" "$path"
    
    # 3. Universal DBUS reload (works on Plasma 5 and 6)
    # This replaces the qdbus6 command
    dbus-send --type=method_call --dest=org.kde.kglobalaccel \
        /kglobalaccel org.kde.KGlobalAccel.rebindShortcut string:"$name"
}

# Apply both
register_kde_shortcut "$NAME_J" "$HOTKEY_J" "$SCRIPT_J"
register_kde_shortcut "$NAME_H" "$HOTKEY_H" "$SCRIPT_H"

echo "Success: Registered J ($HOTKEY_J) and H ($HOTKEY_H)"
