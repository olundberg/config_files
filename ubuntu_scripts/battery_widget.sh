mkdir -p ~/.local/share/plasma/plasmoids/com.oscar.batterypower/contents/ui

cat > ~/.local/share/plasma/plasmoids/com.oscar.batterypower/metadata.json <<'EOF'
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
EOF

cat > ~/.local/share/plasma/plasmoids/com.oscar.batterypower/contents/ui/main.qml <<'EOF'
import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support

PlasmoidItem {
    id: root

    property string batteryPath: ""
    property string status: "Unknown"
    property real watts: 0
    property string displayText: "… W"
    property string details: "Reading battery information…"

    Plasmoid.title: "Battery Power Rate"
    Plasmoid.icon: status === "Charging"
        ? "battery-charging"
        : "battery"

    preferredRepresentation: fullRepresentation

    Layout.minimumWidth: label.implicitWidth + 12
    Layout.preferredWidth: label.implicitWidth + 12
    Layout.minimumHeight: label.implicitHeight
    Layout.preferredHeight: label.implicitHeight

    toolTipMainText: displayText
    toolTipSubText: details

    function shellQuote(value) {
        return "'" + String(value).replace(/'/g, "'\\''") + "'"
    }

    function updateBattery() {
        var command =
            "battery=$(find /sys/class/power_supply -maxdepth 1 " +
            "-type l -name 'BAT*' | sort | head -n1); " +
            "if [ -z \"$battery\" ]; then " +
                "printf 'ERROR|No battery found'; " +
                "exit; " +
            "fi; " +
            "status=$(cat \"$battery/status\" 2>/dev/null); " +
            "capacity=$(cat \"$battery/capacity\" 2>/dev/null); " +
            "voltage=$(cat \"$battery/voltage_now\" 2>/dev/null); " +
            "if [ -r \"$battery/power_now\" ]; then " +
                "power=$(cat \"$battery/power_now\"); " +
            "elif [ -r \"$battery/current_now\" ] && " +
                 "[ -r \"$battery/voltage_now\" ]; then " +
                "current=$(cat \"$battery/current_now\"); " +
                "power=$((current * voltage / 1000000)); " +
            "else " +
                "power=0; " +
            "fi; " +
            "printf '%s|%s|%s|%s|%s' " +
                "\"$battery\" \"$status\" \"$capacity\" \"$power\" \"$voltage\""

        executable.connectSource(command)
    }

    function processOutput(output) {
        var parts = output.trim().split("|")

        if (parts.length < 2 || parts[0] === "ERROR") {
            displayText = "No battery"
            details = parts.length > 1 ? parts[1] : "Could not read battery"
            watts = 0
            return
        }

        batteryPath = parts[0]
        status = parts[1]

        var capacity = Number(parts[2])
        var microwatts = Number(parts[3])
        var microvolts = Number(parts[4])

        if (!isFinite(microwatts)) {
            microwatts = 0
        }

        watts = microwatts / 1000000.0

        var prefix = ""
        if (status === "Charging") {
            prefix = "+"
        } else if (status === "Discharging") {
            prefix = "−"
        }

        displayText = prefix + watts.toFixed(1) + " W"

        var detailLines = []

        detailLines.push(status)

        if (isFinite(capacity)) {
            detailLines.push(capacity.toFixed(0) + "%")
        }

        if (isFinite(microvolts) && microvolts > 0) {
            detailLines.push((microvolts / 1000000.0).toFixed(2) + " V")
        }

        details = detailLines.join(" · ")
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"

        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)

            if (data["exit code"] !== 0) {
                root.displayText = "Error"
                root.details = data.stderr || "Command failed"
                return
            }

            root.processOutput(data.stdout || "")
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: root.updateBattery()
    }

    fullRepresentation: Item {
        implicitWidth: label.implicitWidth + 12
        implicitHeight: Math.max(label.implicitHeight, 24)

        PlasmaComponents.Label {
            id: label

            anchors.centerIn: parent

            text: root.displayText
            font.weight: Font.DemiBold
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
EOF
