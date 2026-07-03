#!/bin/bash
# Install script for Samsung Bluetooth Keyboard Remapping (KDE Plasma/Wayland/X11)
# Bypasses display server abstraction layers by injecting modifications directly into udev hwdb.

set -e # Exit instantly if any command fails

HWDB_FILE="/etc/udev/hwdb.d/99-bluetooth-keyboard.hwdb"

# Ensure the script is executed with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: This script must be run as root (use sudo)." >&2
    exit 1
fi

echo "========================================================"
echo "📦 Configuring Hardware-Level Key Swap (Samsung BT)"
echo "========================================================"

# 1. Generate the clean hwdb configuration layout
echo "Writing configuration definitions to: $HWDB_FILE"

cat << 'EOF' > "$HWDB_FILE"
# Match line for Samsung Bluetooth Keyboard (v04E8p7021)
# Note: Case-sensitivity on 'E' is mandatory to match kernel sysfs presentation profiles.
evdev:input:b0005v04E8p7021*
 KEYBOARD_KEY_700e2=leftmeta
 KEYBOARD_KEY_700e3=leftalt
EOF

# 2. Recompile the hardware database index
echo "Compiling structural changes into udev binary database..."
systemd-hwdb update

# 3. Reload subsystem rules and broadcast configuration events
echo "Forcing the kernel input subsystem to re-read device profiles..."
udevadm control --reload-rules
udevadm trigger --verbose --sysname-match="event*"

echo "--------------------------------------------------------"
echo "✅ Success! Configuration successfully written and applied."
echo "--------------------------------------------------------"

# 4. Optional: Run diagnostic test check on connected components
echo "Searching for active device targets..."
if cat /proc/bus/input/devices | grep -i "04E8" >/dev/null; then
    echo "✨ Detected matching Samsung keyboard online. The swap is live!"
else
    echo "💡 Note: Samsung Bluetooth keyboard is not currently connected."
    echo "   The swap mapping will apply automatically the moment it pairs."
fi
echo "========================================================"
