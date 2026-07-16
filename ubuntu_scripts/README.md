# Battery Power Rate for KDE Plasma 6

A small KDE Plasma 6 panel widget that shows the laptop battery's current net charging or discharging rate.

Examples:

- `+3.9 W` while charging
- `−12.4 W` while discharging
- `0.0 W` when full or not charging

The widget reads battery information from Linux sysfs:

```text
/sys/class/power_supply/BAT*/
```

It automatically detects the first battery device matching `BAT*`.

## Requirements

- Ubuntu or another Linux distribution
- KDE Plasma 6
- A battery exposing `power_now` under `/sys/class/power_supply/BAT*/`
- `kpackagetool6`

Check that your battery reports power:

```bash
cat /sys/class/power_supply/BAT*/power_now
```

The value is normally reported in microwatts. For example:

```text
3858000
```

means approximately:

```text
3.858 W
```

## Automatic installation

Download or copy `install.sh`, then make it executable:

```bash
chmod +x install.sh
```

Run it:

```bash
./install.sh
```

The installer creates the widget under:

```text
~/.local/share/plasma/plasmoids/com.oscar.batterypower/
```

It then attempts to restart Plasma Shell.

## Add the widget to the panel

1. Right-click the KDE panel.
2. Select **Enter Edit Mode**.
3. Select **Add Widgets**.
4. Search for **Battery Power Rate**.
5. Drag the widget onto the panel.

## Manual installation

Create the widget directories:

```bash
mkdir -p ~/.local/share/plasma/plasmoids/com.oscar.batterypower/contents/ui
```

Create `metadata.json`:

```bash
cat > ~/.local/share/plasma/plasmoids/com.oscar.batterypower/metadata.json <<'EOF_METADATA'
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
```

Create `contents/ui/main.qml`:

```bash
cat > ~/.local/share/plasma/plasmoids/com.oscar.batterypower/contents/ui/main.qml <<'EOF_QML'
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
```

Restart Plasma Shell:

```bash
systemctl --user restart plasma-plasmashell.service
```

If that service does not exist, log out and log back in.

## Change the update interval

Open:

```text
~/.local/share/plasma/plasmoids/com.oscar.batterypower/contents/ui/main.qml
```

Find:

```qml
Timer {
    interval: 3000
```

The interval is measured in milliseconds:

- `1000` = 1 second
- `3000` = 3 seconds
- `5000` = 5 seconds

Restart Plasma after changing it:

```bash
systemctl --user restart plasma-plasmashell.service
```

## Change the horizontal padding

The current widget uses 20 pixels on each side.

Find:

```qml
leftMargin: 20
rightMargin: 20
```

and:

```qml
implicitWidth: compactLabel.implicitWidth + 40
```

For 30 pixels on each side, use:

```qml
leftMargin: 30
rightMargin: 30
```

and change `+ 40` to `+ 60`.

## Verify the widget installation

```bash
kpackagetool6 --type Plasma/Applet --show com.oscar.batterypower
```

Test it in a separate window:

```bash
plasmawindowed com.oscar.batterypower
```

## Troubleshooting

### The widget says "No battery"

Check the battery name:

```bash
ls /sys/class/power_supply/
```

The widget currently looks for devices named `BAT*`.

### The widget says "No power data"

Check whether `power_now` exists:

```bash
ls /sys/class/power_supply/BAT*/power_now
```

Read it directly:

```bash
cat /sys/class/power_supply/BAT*/power_now
```

### The reading changes between charging and discharging

This can happen with a low-power charger when the laptop's consumption is close to or higher than the charger output. The widget displays net battery power, not necessarily the charger's full output.

Monitor the raw values:

```bash
watch -n 0.5 'for d in /sys/class/power_supply/*; do echo "=== $d ==="; cat "$d/status" "$d/online" "$d/power_now" 2>/dev/null; done'
```

### Plasma does not show the updated widget

Restart Plasma:

```bash
systemctl --user restart plasma-plasmashell.service
```

If needed, remove the widget from the panel and add it again.

## Uninstall

Remove the widget from the panel first, then run:

```bash
rm -rf ~/.local/share/plasma/plasmoids/com.oscar.batterypower
systemctl --user restart plasma-plasmashell.service
```
