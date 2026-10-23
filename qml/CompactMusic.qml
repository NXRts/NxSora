import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 240
    implicitHeight: 36

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 12
        spacing: 8

        // Album Art / Music Icon
        Rectangle {
            width: 24
            height: 24
            radius: 6
            color: "#18181f"
            clip: true

            Image {
                anchors.fill: parent
                source: IslandController.mediaArtUrl
                fillMode: Image.PreserveAspectCrop
                visible: IslandController.mediaArtUrl !== ""
            }

            Image {
                anchors.centerIn: parent
                width: 14
                height: 14
                source: "file://" + AppConfig.assetsDir + "/music.svg"
                visible: IslandController.mediaArtUrl === ""
            }
        }

        // Track title & artist
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: IslandController.mediaTitle
                color: "#ffffff"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                text: IslandController.mediaArtist
                color: "#94a3b8"
                font.pixelSize: 9
                font.weight: Font.Normal
                elide: Text.ElideRight
                maximumLineCount: 1
                visible: text !== ""
            }
        }

        // Animated Equalizer Visualizer Bars
        Row {
            spacing: 2
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: [
                    { minH: 4, maxH: 14, dur: 380 },
                    { minH: 3, maxH: 16, dur: 460 },
                    { minH: 5, maxH: 15, dur: 320 },
                    { minH: 4, maxH: 12, dur: 420 }
                ]

                Rectangle {
                    required property var modelData
                    width: 2.5
                    height: IslandController.mediaIsPlaying ? currentH : 4
                    radius: 1.25
                    color: IslandController.mediaIsPlaying ? "#38bdf8" : "#64748b"

                    property real currentH: modelData.minH

                    SequentialAnimation on currentH {
                        running: IslandController.mediaIsPlaying
                        loops: Animation.Infinite
                        NumberAnimation { to: modelData.maxH; duration: modelData.dur; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: modelData.minH; duration: modelData.dur; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }
    }
}
