import QtQuick
import QtQuick.Layouts
import QtMultimedia

Item {
    id: root

    readonly property bool isActive: IslandController.state === "hud-camera"

    // Only activate camera hardware when this HUD is actually visible
    CaptureSession {
        id: captureSession
        camera: Camera {
            id: camera
            active: root.isActive
        }
        videoOutput: mirrorOutput
    }

    Rectangle {
        anchors.fill: parent
        color: "#0a0b12"
        radius: 18
        clip: true

        // 1. Live Video Output (Horizontally Flipped for Natural Mirror View)
        VideoOutput {
            id: mirrorOutput
            anchors.fill: parent
            fillMode: VideoOutput.PreserveAspectCrop

            // Natural mirror transformation
            transform: Scale {
                origin.x: mirrorOutput.width / 2
                origin.y: mirrorOutput.height / 2
                xScale: -1.0
                yScale: 1.0
            }
        }

        // Dark gradient overlay at top and bottom for readable controls
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 46
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#d9000000" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: "#d9000000" }
            }
        }

        // 2. Top Header Bar: Active Indicator + Title + Close Button
        RowLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            spacing: 8
            z: 10

            // Live Red Indicator Pill
            Rectangle {
                height: 20
                radius: 10
                implicitWidth: liveRow.implicitWidth + 12
                color: "#1e1e24"
                border.color: "#ef4444"
                border.width: 1

                RowLayout {
                    id: liveRow
                    anchors.centerIn: parent
                    spacing: 4

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: "#ef4444"

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            running: root.isActive
                            NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                            NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
                        }
                    }

                    Text {
                        text: "Cermin Cepat"
                        color: "#f8fafc"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                    }
                }
            }

            Text {
                text: "• Webcam Siap Rapat"
                color: "#94a3b8"
                font.pixelSize: 9
            }

            Item { Layout.fillWidth: true }

            // Close Button (✕)
            Rectangle {
                width: 22
                height: 22
                radius: 11
                color: closeMouse.containsMouse ? "#3f3f46" : "#27272a"
                border.color: "#3f3f46"
                border.width: 1

                Image {
                    anchors.centerIn: parent
                    width: 10
                    height: 10
                    sourceSize: Qt.size(10, 10)
                    source: "file://" + AppConfig.assetsDir + "/close.svg"
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.closeCameraMirror()
                }
            }
        }

        // 3. Bottom Bar: Quick Hint
        RowLayout {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            spacing: 8
            z: 10

            Rectangle {
                height: 22
                radius: 6
                implicitWidth: hintRow.implicitWidth + 12
                color: "#18181b"
                border.color: "#27272a"
                border.width: 1

                RowLayout {
                    id: hintRow
                    anchors.centerIn: parent
                    spacing: 4
                    Image {
                        width: 10
                        height: 10
                        sourceSize: Qt.size(10, 10)
                        source: "file://" + AppConfig.assetsDir + "/check.svg"
                    }
                    Text {
                        text: "Tekan Esc atau klik silang untuk menutup"
                        color: "#94a3b8"
                        font.pixelSize: 9
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: "NxSora Mirror"
                color: "#64748b"
                font.pixelSize: 9
                font.weight: Font.DemiBold
            }
        }
    }
}

