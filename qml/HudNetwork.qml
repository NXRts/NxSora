import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 310
    implicitHeight: 60

    readonly property bool isConnected: IslandController.networkConnected
    readonly property string ssid: IslandController.networkSsid
    readonly property int signalPct: IslandController.networkSignal
    readonly property color themeColor: isConnected ? "#38bdf8" : "#f43f5e"

    property real rippleScale: 0.75
    property real rippleOpacity: 0.0

    function triggerPeekAnim() {
        peekAnim.stop()
        peekAnim.start()
    }

    Connections {
        target: IslandController
        function onStateChanged() {
            if (IslandController.state === "hud-network") {
                root.triggerPeekAnim()
            }
        }
    }

    SequentialAnimation {
        id: peekAnim
        ParallelAnimation {
            NumberAnimation { target: root; property: "rippleScale"; from: 0.7; to: 1.45; duration: 550; easing.type: Easing.OutCubic }
            NumberAnimation { target: root; property: "rippleOpacity"; from: 0.8; to: 0.0; duration: 550; easing.type: Easing.OutQuad }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 16
        spacing: 12

        // =====================================================================
        // 1. LEFT: CIRCULAR ICON WITH RIPPLE RING
        // =====================================================================
        Item {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40

            // Expanding ripple ring
            Rectangle {
                anchors.centerIn: parent
                width: 38
                height: 38
                radius: 19
                color: "transparent"
                border.color: root.themeColor
                border.width: 1.8
                scale: root.rippleScale
                opacity: root.rippleOpacity
            }

            // Glow circle
            Rectangle {
                anchors.centerIn: parent
                width: 38
                height: 38
                radius: 19
                color: Qt.rgba(root.themeColor.r, root.themeColor.g, root.themeColor.b, 0.16)
                border.color: Qt.rgba(root.themeColor.r, root.themeColor.g, root.themeColor.b, 0.45)
                border.width: 1
            }

            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                sourceSize: Qt.size(18, 18)
                source: "file://" + AppConfig.assetsDir + "/network.svg"
            }
        }

        // =====================================================================
        // 2. CENTER: SSID NAME + CONNECTION STATUS
        // =====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.ssid !== "" ? root.ssid : (root.isConnected ? "Wi-Fi Terhubung" : "Wi-Fi Terputus")
                color: "#ffffff"
                font.pixelSize: 13
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.isConnected
                      ? ("Tersambung · Sinyal " + (root.signalPct > 0 ? (root.signalPct + "%") : "Stabil"))
                      : "Koneksi terputus · Mencari sinyal..."
                color: root.isConnected ? "#38bdf8" : "#fda4af"
                font.pixelSize: 10
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
        }

        // =====================================================================
        // 3. RIGHT: SIGNAL STRENGTH BARS (4 BARS)
        // =====================================================================
        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: 3
            visible: root.isConnected

            Repeater {
                model: 4
                Rectangle {
                    required property int index
                    width: 3.5
                    height: 8 + (index * 4) // 8, 12, 16, 20px
                    radius: 1.5
                    anchors.bottom: parent.bottom

                    readonly property real threshold: (index + 1) * 25 // 25, 50, 75, 100
                    color: root.signalPct >= threshold - 15 ? "#38bdf8" : "#27273a"

                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }
        }

        // Disconnected icon indicator when not connected
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            visible: !root.isConnected
            width: 22
            height: 22
            radius: 11
            color: "#381822"
            border.color: "#f43f5e"
            border.width: 1

            Image {
                anchors.centerIn: parent
                width: 10
                height: 10
                sourceSize: Qt.size(10, 10)
                source: "file://" + AppConfig.assetsDir + "/close.svg"
            }
        }
    }
}
