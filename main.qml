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
        interval: 5000
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
