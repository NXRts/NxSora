import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    implicitWidth: 390
    implicitHeight: 185

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Top Header: Album Art + Track Info + Close Button
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Album Art
            Rectangle {
                width: 52
                height: 52
                radius: 12
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
                    width: 24
                    height: 24
                    source: "file://" + AppConfig.assetsDir + "/music.svg"
                    visible: IslandController.mediaArtUrl === ""
                }
            }

            // Track details
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: IslandController.mediaTitle
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    Layout.fillWidth: true
                    text: IslandController.mediaArtist
                    color: "#94a3b8"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    Layout.fillWidth: true
                    text: IslandController.mediaAlbum
                    color: "#64748b"
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    visible: text !== ""
                }
            }

            // Close Button
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: closeMouse.containsMouse ? "#3b3b4a" : "#1e1e28"
                border.color: "#2d2d3c"
                border.width: 1
                Layout.alignment: Qt.AlignTop

                Image {
                    anchors.centerIn: parent
                    width: 12
                    height: 12
                    source: "file://" + AppConfig.assetsDir + "/close.svg"
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.collapse()
                }
            }
        }

        // Timeline Progress Bar
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            // Interactive Progress Bar
            Rectangle {
                id: progressBar
                Layout.fillWidth: true
                height: 6
                radius: 3
                color: "#27272a"

                Rectangle {
                    width: progressBar.width * IslandController.mediaPositionRatio
                    height: parent.height
                    radius: parent.radius
                    color: "#38bdf8"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => {
                        var ratio = Math.max(0.0, Math.min(1.0, mouse.x / width))
                        IslandController.mediaSeek(ratio)
                    }
                }
            }

            // Time stamps
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: IslandController.mediaPositionFormatted
                    color: "#94a3b8"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: IslandController.mediaDurationFormatted
                    color: "#94a3b8"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                }
            }
        }

        // Bottom Controls: Prev, Play/Pause, Next & Volume
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Previous button
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: prevMouse.containsMouse ? "#2f313f" : "#1a1b24"
                border.color: prevMouse.containsMouse ? "#475569" : "#282937"
                border.width: 1

                Image {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: "file://" + AppConfig.assetsDir + "/prev.svg"
                }

                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.mediaPrevious()
                }
            }

            // Play / Pause Button (Large circle)
            Rectangle {
                width: 44
                height: 44
                radius: 22
                color: playMouse.containsMouse ? "#0284c7" : "#0ea5e9"

                Image {
                    anchors.centerIn: parent
                    width: 18
                    height: 18
                    source: IslandController.mediaIsPlaying
                            ? "file://" + AppConfig.assetsDir + "/pause.svg"
                            : "file://" + AppConfig.assetsDir + "/play.svg"
                }

                MouseArea {
                    id: playMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.mediaPlayPause()
                }
            }

            // Next button
            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: nextMouse.containsMouse ? "#2f313f" : "#1a1b24"
                border.color: nextMouse.containsMouse ? "#475569" : "#282937"
                border.width: 1

                Image {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: "file://" + AppConfig.assetsDir + "/next.svg"
                }

                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.mediaNext()
                }
            }

            Item { Layout.fillWidth: true }

            // Inline Volume Slider
            RowLayout {
                spacing: 8

                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: volMuteMouse.containsMouse ? "#2f313f" : "#1a1b24"
                    border.color: "#282937"
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        width: 14
                        height: 14
                        source: IslandController.isMuted
                                ? "file://" + AppConfig.assetsDir + "/volume-mute.svg"
                                : "file://" + AppConfig.assetsDir + "/volume-high.svg"
                    }

                    MouseArea {
                        id: volMuteMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.toggleMute()
                    }
                }

                Rectangle {
                    id: volBar
                    width: 70
                    height: 6
                    radius: 3
                    color: "#27272a"

                    Rectangle {
                        width: volBar.width * IslandController.volume
                        height: parent.height
                        radius: parent.radius
                        color: IslandController.isMuted ? "#ef4444" : "#38bdf8"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            var ratio = Math.max(0.0, Math.min(1.0, mouse.x / width))
                            IslandController.setVolume(ratio)
                        }
                    }
                }
            }
        }
    }
}
