import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property bool isAdzan: IslandController.prayerAlertType === "adzan"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        spacing: 10

        // Glowing Crescent Icon
        Rectangle {
            Layout.preferredWidth: root.isAdzan ? 30 : 26
            Layout.preferredHeight: root.isAdzan ? 30 : 26
            radius: width / 2
            color: root.isAdzan ? "#78350f" : "#1e1b4b"
            border.color: root.isAdzan ? "#f59e0b" : "#818cf8"
            border.width: 1
            Layout.alignment: Qt.AlignVCenter

            Image {
                anchors.centerIn: parent
                width: root.isAdzan ? 15 : 13
                height: root.isAdzan ? 15 : 13
                sourceSize.width: width
                sourceSize.height: height
                source: "file://" + AppConfig.assetsDir + "/crescent.svg"
            }
        }

        // Text Info Readout
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Layout.alignment: Qt.AlignVCenter

            RowLayout {
                spacing: 6
                Text {
                    text: IslandController.prayerAlertName
                    color: root.isAdzan ? "#fbbf24" : "#ffffff"
                    font.pixelSize: root.isAdzan ? 12 : 11
                    font.weight: Font.Bold
                }

                Text {
                    visible: root.isAdzan
                    text: "• Waktu Sholat Tiba"
                    color: "#94a3b8"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }

            Text {
                visible: !root.isAdzan
                text: "10 menit lagi menuju waktu sholat"
                color: "#94a3b8"
                font.pixelSize: 9
            }
        }

        // Right Badge / Time
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            height: 22
            radius: 11
            color: root.isAdzan ? "#052e16" : "#1e293b"
            border.color: root.isAdzan ? "#10b981" : "#38bdf8"
            border.width: 1
            implicitWidth: timeBadgeText.implicitWidth + 14

            Text {
                id: timeBadgeText
                anchors.centerIn: parent
                text: root.isAdzan ? (IslandController.prayerAlertExtra + " WIB") : IslandController.prayerAlertExtra
                color: root.isAdzan ? "#4ade80" : "#38bdf8"
                font.pixelSize: 10
                font.weight: Font.Bold
            }
        }
    }
}
