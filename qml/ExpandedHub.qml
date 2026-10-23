import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    implicitWidth: 400
    implicitHeight: 235

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Top Row: Title + Music Switch + Close
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "Dynamic Control Hub"
                color: "#f8fafc"
                font.pixelSize: 13
                font.weight: Font.Bold
            }

            Item { Layout.fillWidth: true }

            // Switch to Music (if track exists)
            Rectangle {
                visible: IslandController.mediaHasTrack
                width: 80
                height: 26
                radius: 13
                color: musicSwitchMouse.containsMouse ? "#2f313f" : "#1a1b24"
                border.color: "#282937"
                border.width: 1

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 5
                    Image {
                        width: 12
                        height: 12
                        source: "file://" + AppConfig.assetsDir + "/music.svg"
                    }
                    Text {
                        text: "Musik"
                        color: "#38bdf8"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }

                MouseArea {
                    id: musicSwitchMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.expandMusic()
                }
            }

            // Close button
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: closeMouse.containsMouse ? "#3b3b4a" : "#1e1e28"
                border.color: "#2d2d3c"
                border.width: 1

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

        // System Resource Meters (CPU & RAM & Battery)
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // CPU Card
            Rectangle {
                Layout.fillWidth: true
                height: 58
                radius: 10
                color: "#121217"
                border.color: "#22222a"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Image {
                            width: 12
                            height: 12
                            source: "file://" + AppConfig.assetsDir + "/cpu.svg"
                        }
                        Text {
                            text: "CPU"
                            color: "#94a3b8"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: IslandController.cpuPercent + "%"
                            color: "#f8fafc"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: "#27272a"
                        Rectangle {
                            width: parent.width * (IslandController.cpuPercent / 100.0)
                            height: parent.height
                            radius: parent.radius
                            color: IslandController.cpuPercent > 80 ? "#ef4444" : "#38bdf8"
                        }
                    }
                }
            }

            // RAM Card
            Rectangle {
                Layout.fillWidth: true
                height: 58
                radius: 10
                color: "#121217"
                border.color: "#22222a"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Image {
                            width: 12
                            height: 12
                            source: "file://" + AppConfig.assetsDir + "/memory.svg"
                        }
                        Text {
                            text: "RAM"
                            color: "#94a3b8"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: IslandController.ramPercent + "%"
                            color: "#f8fafc"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: "#27272a"
                        Rectangle {
                            width: parent.width * (IslandController.ramPercent / 100.0)
                            height: parent.height
                            radius: parent.radius
                            color: IslandController.ramPercent > 85 ? "#ef4444" : "#818cf8"
                        }
                    }
                }
            }

            // Battery Card
            Rectangle {
                Layout.fillWidth: true
                height: 58
                radius: 10
                color: "#121217"
                border.color: "#22222a"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Image {
                            width: 12
                            height: 12
                            source: IslandController.isCharging 
                                    ? "file://" + AppConfig.assetsDir + "/bolt.svg"
                                    : "file://" + AppConfig.assetsDir + "/battery.svg"
                        }
                        Text {
                            text: IslandController.isCharging ? "Charging" : "Battery"
                            color: "#94a3b8"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: IslandController.batteryPercent + "%"
                            color: IslandController.isCharging ? "#22c55e" : "#f8fafc"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: "#27272a"
                        Rectangle {
                            width: parent.width * (IslandController.batteryPercent / 100.0)
                            height: parent.height
                            radius: parent.radius
                            color: IslandController.isCharging ? "#22c55e" : "#38bdf8"
                        }
                    }
                }
            }
        }

        // Quick Utilities: Timer & Notification Test & Mute
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Timer Widget Box
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 10
                color: "#121217"
                border.color: "#22222a"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Image {
                        width: 14
                        height: 14
                        source: "file://" + AppConfig.assetsDir + "/timer.svg"
                    }

                    Text {
                        text: IslandController.timerRemaining > 0 ? IslandController.timerFormatted : "Timer"
                        color: IslandController.timerRunning ? "#f59e0b" : "#f8fafc"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }

                    Item { Layout.fillWidth: true }

                    // Preset buttons
                    Row {
                        spacing: 4
                        visible: IslandController.timerRemaining === 0

                        Repeater {
                            model: [
                                { label: "1m", sec: 60 },
                                { label: "5m", sec: 300 },
                                { label: "25m", sec: 1500 }
                            ]
                            Rectangle {
                                required property var modelData
                                width: 28
                                height: 22
                                radius: 4
                                color: btnMouse.containsMouse ? "#27272a" : "#1a1a22"

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: "#cbd5e1"
                                    font.pixelSize: 9
                                }

                                MouseArea {
                                    id: btnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: IslandController.startTimer(modelData.sec)
                                }
                            }
                        }
                    }

                    // Running Timer Controls
                    Row {
                        spacing: 4
                        visible: IslandController.timerRemaining > 0

                        Rectangle {
                            width: 44
                            height: 22
                            radius: 4
                            color: pauseMouse.containsMouse ? "#27272a" : "#1a1a22"
                            Text {
                                anchors.centerIn: parent
                                text: IslandController.timerRunning ? "Pause" : "Start"
                                color: "#38bdf8"
                                font.pixelSize: 9
                            }
                            MouseArea {
                                id: pauseMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: IslandController.toggleTimer()
                            }
                        }

                        Rectangle {
                            width: 36
                            height: 22
                            radius: 4
                            color: resetMouse.containsMouse ? "#27272a" : "#1a1a22"
                            Text {
                                anchors.centerIn: parent
                                text: "Reset"
                                color: "#ef4444"
                                font.pixelSize: 9
                            }
                            MouseArea {
                                id: resetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: IslandController.resetTimer()
                            }
                        }
                    }
                }
            }

            // Quick Mute Toggle Button
            Rectangle {
                width: 50
                height: 52
                radius: 10
                color: muteBtnMouse.containsMouse ? "#27272a" : "#121217"
                border.color: IslandController.isMuted ? "#ef4444" : "#22222a"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2
                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        width: 14
                        height: 14
                        source: IslandController.isMuted
                                ? "file://" + AppConfig.assetsDir + "/volume-mute.svg"
                                : "file://" + AppConfig.assetsDir + "/volume-high.svg"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: IslandController.isMuted ? "Unmute" : "Mute"
                        color: IslandController.isMuted ? "#ef4444" : "#94a3b8"
                        font.pixelSize: 8
                    }
                }

                MouseArea {
                    id: muteBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.toggleMute()
                }
            }

            // Test Notification Trigger Button
            Rectangle {
                width: 50
                height: 52
                radius: 10
                color: testNotifMouse.containsMouse ? "#27272a" : "#121217"
                border.color: "#22222a"
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 2
                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        width: 14
                        height: 14
                        source: "file://" + AppConfig.assetsDir + "/bell.svg"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Test"
                        color: "#94a3b8"
                        font.pixelSize: 8
                    }
                }

                MouseArea {
                    id: testNotifMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        IslandController.collapse()
                        IslandController.triggerTestNotification()
                    }
                }
            }
        }
    }
}
