import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 310
    implicitHeight: 60

    readonly property color ringColor: {
        if (IslandController.isCharging) return "#33e07a";
        if (IslandController.batteryPercent < 20) return "#ef4444";
        return "#38bdf8";
    }

    property real sweepRatio: Math.max(0.05, Math.min(1.0, IslandController.batteryPercent / 100.0))
    property real rippleScale: 0.75
    property real rippleOpacity: 0.0
    property real boltScale: 1.0

    onSweepRatioChanged: battRingCanvas.requestPaint()

    function triggerChargeAnim() {
        chargeAnim.stop()
        sweepRatio = 0.0
        chargeAnim.start()
    }

    Connections {
        target: IslandController
        function onStateChanged() {
            if (IslandController.state === "hud-battery") {
                root.triggerChargeAnim()
            }
        }
        function onBatteryChanged() {
            battRingCanvas.requestPaint()
        }
    }

    ParallelAnimation {
        id: chargeAnim
        NumberAnimation {
            target: root
            property: "sweepRatio"
            from: 0.0
            to: Math.max(0.05, Math.min(1.0, IslandController.batteryPercent / 100.0))
            duration: 640
            easing.type: Easing.OutCubic
        }
        SequentialAnimation {
            ParallelAnimation {
                NumberAnimation { target: root; property: "rippleScale"; from: 0.75; to: 1.45; duration: 550; easing.type: Easing.OutCubic }
                NumberAnimation { target: root; property: "rippleOpacity"; from: 0.7; to: 0.0; duration: 550; easing.type: Easing.OutQuad }
            }
        }
        SequentialAnimation {
            NumberAnimation { target: root; property: "boltScale"; from: 0.6; to: 1.25; duration: 220; easing.type: Easing.OutBack }
            NumberAnimation { target: root; property: "boltScale"; to: 1.0; duration: 240; easing.type: Easing.OutElastic }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 16
        spacing: 12

        // =====================================================================
        // 1. LEFT: NUSA NEON-GREEN CIRCULAR CONIC RING + LIGHTNING BOLT
        // =====================================================================
        Item {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40

            // Expanding electric ripple ring
            Rectangle {
                anchors.centerIn: parent
                width: 38
                height: 38
                radius: 19
                color: "transparent"
                border.color: root.ringColor
                border.width: 1.8
                scale: root.rippleScale
                opacity: root.rippleOpacity
            }

            // Soft outer neon glow
            Rectangle {
                anchors.centerIn: parent
                width: 38
                height: 38
                radius: 19
                color: IslandController.isCharging
                       ? Qt.rgba(0.20, 0.88, 0.48, 0.16)
                       : Qt.rgba(0.22, 0.74, 0.97, 0.10)
            }

            Canvas {
                id: battRingCanvas
                anchors.fill: parent
                antialiasing: true

                property int pct: IslandController.batteryPercent
                property bool charging: IslandController.isCharging
                onPctChanged: requestPaint()
                onChargingChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var cx = width / 2;
                    var cy = height / 2;
                    var r = (Math.min(width, height) / 2) - 3;

                    // Dark track circle
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, Math.PI * 2);
                    ctx.lineWidth = 3.4;
                    ctx.strokeStyle = "#192622";
                    ctx.stroke();

                    // Active animated progress arc
                    var ratio = Math.max(0.03, Math.min(1.0, root.sweepRatio));
                    var startAngle = -Math.PI / 2;
                    var endAngle = startAngle + (Math.PI * 2 * ratio);
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, startAngle, endAngle, false);
                    ctx.lineWidth = 3.4;
                    ctx.lineCap = "round";
                    ctx.strokeStyle = charging ? "#33e07a" : (pct < 20 ? "#ef4444" : "#38bdf8");
                    ctx.stroke();
                }
            }

            // Lightning Bolt / Battery Icon Centered Inside Ring
            Image {
                anchors.centerIn: parent
                width: 15
                height: 15
                scale: root.boltScale
                sourceSize.width: 15
                sourceSize.height: 15
                source: IslandController.isCharging
                        ? "file://" + AppConfig.assetsDir + "/bolt.svg"
                        : "file://" + AppConfig.assetsDir + "/battery.svg"
            }
        }

        // =====================================================================
        // 2. CENTER: CHARGING TITLE + SUBTITLE (Nusa Style)
        // =====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: IslandController.isCharging ? "Charging" : "Mode Baterai"
                color: "#ffffff"
                font.pixelSize: 13
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: IslandController.isCharging
                      ? "Charger connected · Fast Power"
                      : "Charger dilepas · Menggunakan baterai"
                color: IslandController.isCharging ? "#33e07a" : "#94a3b8"
                font.pixelSize: 10
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }

        // =====================================================================
        // 3. RIGHT: LARGE PERCENTAGE READOUT (Nusa 22px Bold Style)
        // =====================================================================
        Text {
            text: IslandController.batteryPercent + "%"
            color: IslandController.isCharging ? "#33e07a" : "#f8fafc"
            font.pixelSize: 22
            font.weight: Font.ExtraBold
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
