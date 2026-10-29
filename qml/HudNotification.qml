import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 330
    implicitHeight: 56

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        spacing: 10

        // Notification Icon circle
        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 34
            radius: 17
            color: "#1e1b4b"
            border.color: "#4f46e5"
            border.width: 1
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.centerIn: parent
                width: 16
                height: 16
                source: "file://" + AppConfig.assetsDir + "/bell.svg"
                sourceSize.width: 16
                sourceSize.height: 16
            }
        }

        // Notification Texts
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.minimumWidth: 0
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            RowLayout {
                Layout.fillWidth: true
                spacing: 5
                Text {
                    text: IslandController.notifApp || "Sistem"
                    color: "#818cf8"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                Text {
                    text: "• Baru saja"
                    color: "#64748b"
                    font.pixelSize: 9
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: IslandController.notifTitle
                color: "#f8fafc"
                font.pixelSize: 11
                font.weight: Font.Bold
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                text: IslandController.notifBody
                color: "#94a3b8"
                font.pixelSize: 10
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
            }
        }

        // Right "Baca" Pill Badge with Chevron
        Rectangle {
            Layout.preferredWidth: readRow.implicitWidth + 14
            Layout.preferredHeight: 22
            radius: 11
            color: hudClickMouse.containsMouse ? "#312e81" : "#1e1b4b"
            border.color: "#6366f1"
            border.width: 1

            RowLayout {
                id: readRow
                anchors.centerIn: parent
                spacing: 3

                Text {
                    text: "Baca"
                    color: "#c7d2fe"
                    font.pixelSize: 9
                    font.weight: Font.Bold
                }

                Image {
                    width: 8
                    height: 8
                    sourceSize: Qt.size(8, 8)
                    source: "file://" + AppConfig.assetsDir + "/chevron-right.svg"
                }
            }
        }
    }

    MouseArea {
        id: hudClickMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: IslandController.expandToNotifications()
    }
}
