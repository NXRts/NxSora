import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // =====================================================================
        // SECTION 1: WATER INTAKE TRACKER (NUSA & PONI STYLE)
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: "#121420"
            border.color: "#1e2235"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Title row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        width: 24
                        height: 24
                        radius: 6
                        color: "#0284c7"
                        Text {
                            anchors.centerIn: parent
                            text: "💧"
                            font.pixelSize: 12
                        }
                    }

                    Text {
                        text: "Pelacak Minum Air"
                        color: "#f8fafc"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: IslandController.waterPercent + "% Target"
                        color: IslandController.waterPercent >= 100 ? "#22c55e" : "#38bdf8"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                }

                // Volume Progress Big Text
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: (IslandController.waterIntake / 1000.0).toFixed(2)
                        color: "#f8fafc"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "/ " + (IslandController.waterGoal / 1000.0).toFixed(1) + " Liter"
                        color: "#94a3b8"
                        font.pixelSize: 12
                        Layout.alignment: Qt.AlignBaseline
                    }

                    Item { Layout.fillWidth: true }

                    // Quick Drink Button (+250ml)
                    Rectangle {
                        width: 90
                        height: 28
                        radius: 14
                        color: drinkMouse.containsMouse ? "#0284c7" : "#0369a1"
                        border.color: "#38bdf8"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                text: "🥤"
                                font.pixelSize: 11
                            }
                            Text {
                                text: "+250 ml"
                                color: "#ffffff"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            id: drinkMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.drinkWater(250)
                        }
                    }

                    // Reset button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: resetMouse.containsMouse ? "#334155" : "#1e293b"
                        border.color: "#334155"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "↺"
                            color: "#94a3b8"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: resetMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.resetWater()
                        }
                    }
                }

                // Horizontal Progress Bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: "#1e293b"
                    clip: true

                    Rectangle {
                        width: parent.width * IslandController.waterProgressRatio
                        height: parent.height
                        radius: 4
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#06b6d4" }
                            GradientStop { position: 1.0; color: "#38bdf8" }
                        }
                        Behavior on width {
                            NumberAnimation { duration: 350; easing.type: Easing.OutQuad }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // SECTION 2: EYE BREAK (20-20-20 RULE) & MASCOT TOGGLE
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // 20-20-20 Eye Break Card
            Rectangle {
                Layout.fillWidth: true
                height: 64
                radius: 12
                color: "#121420"
                border.color: "#1e2235"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: "#059669"
                        Text {
                            anchors.centerIn: parent
                            text: "👁️"
                            font.pixelSize: 13
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "Jeda Mata 20-20-20"
                            color: "#f8fafc"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                        Text {
                            text: "Sisa: " + IslandController.eyeBreakFormatted
                            color: "#34d399"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 60
                        height: 24
                        radius: 12
                        color: eyeMouse.containsMouse ? "#047857" : "#065f46"
                        Text {
                            anchors.centerIn: parent
                            text: "Reset"
                            color: "#ecfdf5"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                        MouseArea {
                            id: eyeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.resetEyeBreak()
                        }
                    }
                }
            }

            // Mode Maskot Mata (Nusa Style) Card
            Rectangle {
                Layout.fillWidth: true
                height: 64
                radius: 12
                color: mascotCardMouse.containsMouse ? "#191c2c" : "#121420"
                border.color: IslandController.mascotMode ? "#38bdf8" : "#1e2235"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: IslandController.mascotMode ? "#0284c7" : "#334155"
                        Text {
                            anchors.centerIn: parent
                            text: "👀"
                            font.pixelSize: 13
                        }
                    }

                    ColumnLayout {
                        spacing: 2
                        Text {
                            text: "Maskot Santai"
                            color: "#f8fafc"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }
                        Text {
                            text: IslandController.mascotMode ? "Mata Berkedip Aktif" : "Jam Digital Standar"
                            color: IslandController.mascotMode ? "#38bdf8" : "#94a3b8"
                            font.pixelSize: 10
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        width: 32
                        height: 18
                        radius: 9
                        color: IslandController.mascotMode ? "#38bdf8" : "#334155"

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            anchors.verticalCenter: parent.verticalCenter
                            x: IslandController.mascotMode ? parent.width - width - 2 : 2
                            color: "#ffffff"
                            Behavior on x { NumberAnimation { duration: 150 } }
                        }
                    }
                }

                MouseArea {
                    id: mascotCardMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.toggleMascotMode()
                }
            }
        }
    }
}
