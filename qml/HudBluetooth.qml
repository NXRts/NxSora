import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 310
    implicitHeight: 60

    readonly property color accentColor: IslandController.btDeviceConnected ? "#5ec2ff" : "#64748b"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        // =====================================================================
        // 1. LEFT: CIRCULAR BATTERY CONIC RING + BLUETOOTH ICON (Nusa Style)
        // =====================================================================
        Item {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40

            // Soft outer glow behind ring
            Rectangle {
                anchors.centerIn: parent
                width: 38
                height: 38
                radius: 19
                color: Qt.rgba(0.37, 0.76, 1.0, IslandController.btDeviceConnected ? 0.14 : 0.04)
            }

            Canvas {
                id: btRingCanvas
                anchors.fill: parent
                antialiasing: true

                property int batteryPct: IslandController.btDeviceBattery
                property bool isConnected: IslandController.btDeviceConnected
                onBatteryPctChanged: requestPaint()
                onIsConnectedChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var cx = width / 2;
                    var cy = height / 2;
                    var r = (Math.min(width, height) / 2) - 3;

                    // Track circle
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, Math.PI * 2);
                    ctx.lineWidth = 3.2;
                    ctx.strokeStyle = "#1b2838";
                    ctx.stroke();

                    // Progress arc
                    var ratio = isConnected ? Math.max(0.08, Math.min(1.0, batteryPct / 100.0)) : 0.0;
                    if (ratio > 0) {
                        var startAngle = -Math.PI / 2;
                        var endAngle = startAngle + (Math.PI * 2 * ratio);
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, startAngle, endAngle, false);
                        ctx.lineWidth = 3.2;
                        ctx.lineCap = "round";
                        ctx.strokeStyle = "#5ec2ff";
                        ctx.stroke();
                    }
                }
            }

            // Center Bluetooth Rune Symbol
            Canvas {
                anchors.centerIn: parent
                width: 14
                height: 16
                antialiasing: true
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.strokeStyle = "#5ec2ff";
                    ctx.lineWidth = 1.6;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";
                    ctx.beginPath();
                    ctx.moveTo(4, 4);
                    ctx.lineTo(10, 12);
                    ctx.lineTo(7, 15);
                    ctx.lineTo(7, 1);
                    ctx.lineTo(10, 4);
                    ctx.lineTo(4, 12);
                    ctx.stroke();
                }
            }
        }

        // =====================================================================
        // 2. CENTER: DEVICE NAME + CONNECTION & BATTERY STATUS
        // =====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: IslandController.btDeviceName
                color: "#ffffff"
                font.pixelSize: 13
                font.weight: Font.Bold
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            RowLayout {
                spacing: 5

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: IslandController.btDeviceConnected ? "#5ec2ff" : "#64748b"
                }

                Text {
                    text: IslandController.btDeviceConnected
                          ? ("Tersambung · " + IslandController.btDeviceBattery + "%")
                          : "Terputus (Disconnected)"
                    color: IslandController.btDeviceConnected ? "#5ec2ff" : "#94a3b8"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }
        }

        // =====================================================================
        // 3. RIGHT: GLOWING HEADPHONE BADGE CIRCLE (Nusa Style)
        // =====================================================================
        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 19
            color: "#112236"
            border.color: IslandController.btDeviceConnected ? "#5ec2ff" : "#334155"
            border.width: 1.5

            // Crisp Vector Headphone Icon
            Canvas {
                anchors.centerIn: parent
                width: 18
                height: 18
                antialiasing: true
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.strokeStyle = "#f8fafc";
                    ctx.lineWidth = 1.8;
                    ctx.lineCap = "round";

                    // Headband arc
                    ctx.beginPath();
                    ctx.arc(9, 9, 6.5, Math.PI, 0, false);
                    ctx.stroke();

                    // Left earcup
                    ctx.fillStyle = "#5ec2ff";
                    ctx.beginPath();
                    ctx.roundRect(1.5, 9, 3.5, 6, 1.5);
                    ctx.fill();

                    // Right earcup
                    ctx.beginPath();
                    ctx.roundRect(13, 9, 3.5, 6, 1.5);
                    ctx.fill();
                }
            }
        }
    }
}

