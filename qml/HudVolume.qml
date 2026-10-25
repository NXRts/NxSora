import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 230
    implicitHeight: 32

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // Speaker Icon
        Image {
            width: 16
            height: 16
            source: IslandController.isMuted 
                    ? "file://" + AppConfig.assetsDir + "/volume-mute.svg"
                    : "file://" + AppConfig.assetsDir + "/volume-high.svg"
            sourceSize.width: 16
            sourceSize.height: 16
        }

        // Animated Volume Bar
        Rectangle {
            Layout.fillWidth: true
            height: 5
            radius: 2.5
            color: "#27272a"

            Rectangle {
                width: parent.width * IslandController.volume
                height: parent.height
                radius: parent.radius
                color: IslandController.isMuted ? "#ef4444" : "#38bdf8"

                Behavior on width {
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                }
            }
        }

        // Percentage Text
        Text {
            text: IslandController.isMuted ? "Muted" : (IslandController.volumePercent + "%")
            color: IslandController.isMuted ? "#ef4444" : "#f1f5f9"
            font.pixelSize: 11
            font.weight: Font.DemiBold
            Layout.preferredWidth: 38
            horizontalAlignment: Text.AlignRight
        }
    }
}
