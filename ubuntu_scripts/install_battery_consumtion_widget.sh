#!/usr/bin/env bash

set -euo pipefail

WIDGET_ID="com.oscar.batterypower"
WIDGET_DIR="${HOME}/.local/share/plasma/plasmoids/${WIDGET_ID}"
UI_DIR="${WIDGET_DIR}/contents/ui"

printf 'Installing Battery Power Rate for KDE Plasma 6...\n'

if [[ ! -d /sys/class/power_supply ]]; then
    printf 'Error: /sys/class/power_supply does not exist.\n' >&2
    exit 1
fi

BATTERY_PATH="$(find /sys/class/power_supply -maxdepth 1 -type l -name 'BAT*' | sort | head -n 1 || true)"

if [[ -z "${BATTERY_PATH}" ]]; then
    printf 'Warning: no battery matching BAT* was detected.\n' >&2
else
    printf 'Detected battery: %s\n' "${BATTERY_PATH}"

    if [[ ! -r "${BATTERY_PATH}/power_now" ]]; then
        printf 'Warning: %s/power_now is not readable.\n' "${BATTERY_PATH}" >&2
        printf 'The widget may display "No power data".\n' >&2
    fi
fi

mkdir -p "${UI_DIR}"

cat > "${WIDGET_DIR}/metadata.json" <<'EOF_METADATA'
{
    "KPlugin": {
        "Authors": [
            {
                "Name": "Oscar Lundberg"
            }
        ],
        "Category": "System Information",
        "Description": "Shows the current net battery charging or discharging rate",
        "Icon": "battery",
        "Id": "com.oscar.batterypower",
        "Name": "Battery Power Rate",
        "Version": "1.0",
        "Website": ""
    },
    "KPackageStructure": "Plasma/Applet",
    "X-Plasma-API-Minimum-Version": "6.0"
}
EOF_METADATA

cat > "${UI_DIR}/main.qml" <<'EOF_QML'
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    property string displayText: "… W"
    property string details: "Reading battery information…"
    property string batteryStatus: "Unknown"

    Plasmoid.title: "Battery Power Rate"

    Plasmoid.icon: batteryStatus === "Charging"
        ? "battery-charging"
        : "battery"

    preferredRepresentation: compactRepresentation

    toolTipMainText: displayText
    toolTipSubText: details

    function updateBattery() {
        const command =
            "BAT=$(find /sys/class/power_supply -maxdepth 1 " +
            "-name 'BAT*' -type l | sort | head -n 1); " +
            "if [ -z \"$BAT\" ]; then " +
                "printf 'ERROR\\nNo battery found\\n'; " +
            "else " +
                "cat \"$BAT/status\" 2>/dev/null; " +
                "cat \"$BAT/power_now\" 2>/dev/null; " +
                "cat \"$BAT/capacity\" 2>/dev/null; " +
                "cat \"$BAT/voltage_now\" 2>/dev/null; " +
            "fi"

        executable.connectSource(command)
    }

    function processOutput(output) {
        const lines = output.trim().split(/\r?\n/)

        if (lines.length < 2 || lines[0] === "ERROR") {
            displayText = "No battery"
            details = lines.length > 1
                ? lines[1]
                : "Battery data unavailable"
            return
        }

        batteryStatus = lines[0].trim()

        const microwatts = Number(lines[1].trim())
        const capacity = lines.length > 2
            ? Number(lines[2].trim())
            : NaN
        const microvolts = lines.length > 3
            ? Number(lines[3].trim())
            : NaN

        if (!Number.isFinite(microwatts)) {
            displayText = "No power data"
            details = "Could not read power_now"
            return
        }

        const watts = microwatts / 1000000.0

        let prefix = ""

        if (batteryStatus === "Charging") {
            prefix = "+"
        } else if (batteryStatus === "Discharging") {
            prefix = "−"
        }

        displayText = prefix + watts.toFixed(1) + " W"

        let information = batteryStatus

        if (Number.isFinite(capacity)) {
            information += " · " + capacity.toFixed(0) + "%"
        }

        if (Number.isFinite(microvolts)) {
            information += " · "
                + (microvolts / 1000000.0).toFixed(2)
                + " V"
        }

        details = information
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)

            if (data["exit code"] !== 0) {
                root.displayText = "Error"
                root.details = data.stderr || "Battery command failed"
                return
            }

            root.processOutput(data.stdout || "")
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.updateBattery()
    }

    compactRepresentation: Item {
        id: compactItem

        implicitWidth: compactLabel.implicitWidth + 40
        implicitHeight: Math.max(compactLabel.implicitHeight, 24)

        Layout.minimumWidth: compactLabel.implicitWidth + 40
        Layout.preferredWidth: compactLabel.implicitWidth + 40
        Layout.maximumWidth: compactLabel.implicitWidth + 40

        Layout.minimumHeight: implicitHeight
        Layout.preferredHeight: implicitHeight

        PlasmaComponents.Label {
            id: compactLabel

            anchors {
                fill: parent
                leftMargin: 20
                rightMargin: 20
            }

            text: root.displayText
            font.weight: Font.DemiBold

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    fullRepresentation: Item {
        id: fullItem

        implicitWidth: fullLabel.implicitWidth + 40
        implicitHeight: Math.max(fullLabel.implicitHeight, 24)

        Layout.minimumWidth: fullLabel.implicitWidth + 40
        Layout.preferredWidth: fullLabel.implicitWidth + 40

        PlasmaComponents.Label {
            id: fullLabel

            anchors {
                fill: parent
                leftMargin: 20
                rightMargin: 20
            }

            text: root.displayText
            font.weight: Font.DemiBold

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
EOF_QML

printf 'Widget files installed in:\n  %s\n' "${WIDGET_DIR}"

if command -v kpackagetool6 >/dev/null 2>&1; then
    printf '\nVerifying package...\n'
    kpackagetool6 --type Plasma/Applet --show "${WIDGET_ID}" >/dev/null 2>&1 || true
else
    printf '\nWarning: kpackagetool6 was not found.\n' >&2
fi

printf '\nRestarting Plasma Shell...\n'

if systemctl --user restart plasma-plasmashell.service 2>/dev/null; then
    printf 'Plasma Shell restarted.\n'
else
    printf 'Could not restart Plasma automatically. Log out and back in instead.\n'
fi

printf '\nInstallation complete.\n'
printf 'Add the widget by entering panel edit mode, selecting Add Widgets, and searching for "Battery Power Rate".\n'
