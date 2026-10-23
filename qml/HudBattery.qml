import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 240
    implicitHeight: 38

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // Lightning / Battery Icon
        Image {
            width: 16
            height: 16
            source: IslandController.isCharging 
                    ? "file://" + AppConfig.assetsDir + "/bolt.svg"
                    : "file://" + AppConfig.assetsDir + "/battery.svg"
            sourceSize.width: 16
            sourceSize.height: 16
        }

        // Status Text
        Text {
            Layout.fillWidth: true
            text: IslandController.batteryStatusText
            color: IslandController.isCharging ? "#22c55e" : "#f1f5f9"
            font.pixelSize: 11
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }

        // Battery level bar
        Rectangle {
            Layout.preferredWidth: 40
            height: 5
            radius: 2.5
            color: "#27272a"

            Rectangle {
                width: parent.width * (IslandController.batteryPercent / 100.0)
                height: parent.height
                radius: parent.radius
                color: IslandController.isCharging ? "#22c55e" : (IslandController.batteryPercent < 20 ? "#ef4444" : "#38bdf8")
            }
        }
    }
}
