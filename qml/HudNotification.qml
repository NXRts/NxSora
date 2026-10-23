import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 64

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Notification Icon circle
        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: "#1e1b4b"
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: "file://" + AppConfig.assetsDir + "/bell.svg"
                sourceSize.width: 18
                sourceSize.height: 18
            }
        }

        // Notification Texts
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            RowLayout {
                spacing: 6
                Text {
                    text: IslandController.notifApp || "Sistem"
                    color: "#818cf8"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                }
                Text {
                    text: "• sekarang"
                    color: "#64748b"
                    font.pixelSize: 10
                }
            }

            Text {
                Layout.fillWidth: true
                text: IslandController.notifTitle
                color: "#f8fafc"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                text: IslandController.notifBody
                color: "#94a3b8"
                font.pixelSize: 11
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
            }
        }
    }
}
