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
            Layout.preferredHeight: 96
            radius: 14
            color: "#111420"
            border.color: "#1e2238"
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
                        width: 22
                        height: 22
                        radius: 6
                        color: "#0369a1"
                        Text {
                            anchors.centerIn: parent
                            text: "💧"
                            font.pixelSize: 11
                        }
                    }

                    Text {
                        text: "Pelacak Minum Air"
                        color: "#f8fafc"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        height: 20
                        radius: 10
                        color: IslandController.waterPercent >= 100 ? "#052e16" : "#082f49"
                        border.color: IslandController.waterPercent >= 100 ? "#22c55e" : "#0284c7"
                        border.width: 1
                        implicitWidth: percentText.implicitWidth + 14

                        Text {
                            id: percentText
                            anchors.centerIn: parent
                            text: IslandController.waterPercent + "% Target"
                            color: IslandController.waterPercent >= 100 ? "#4ade80" : "#38bdf8"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }
                }

                // Volume Big Text & Action Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text: (IslandController.waterIntake / 1000.0).toFixed(2)
                        color: "#ffffff"
                        font.pixelSize: 22
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "/ " + (IslandController.waterGoal / 1000.0).toFixed(1) + " Liter"
                        color: "#94a3b8"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        Layout.alignment: Qt.AlignBaseline
                    }

                    Item { Layout.fillWidth: true }

                    // Quick Drink Button (+250ml)
                    Rectangle {
                        width: 86
                        height: 26
                        radius: 13
                        color: drinkMouse.containsMouse ? "#0284c7" : "#0369a1"
                        border.color: "#38bdf8"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                text: "🥤"
                                font.pixelSize: 10
                            }
                            Text {
                                text: "+250 ml"
                                color: "#ffffff"
                                font.pixelSize: 10
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
                        width: 26
                        height: 26
                        radius: 13
                        color: resetMouse.containsMouse ? "#334155" : "#1e293b"
                        border.color: "#334155"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "↺"
                            color: resetMouse.containsMouse ? "#f8fafc" : "#94a3b8"
                            font.pixelSize: 12
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
                    height: 6
                    radius: 3
                    color: "#1e293b"
                    clip: true

                    Rectangle {
                        width: parent.width * IslandController.waterProgressRatio
                        height: parent.height
                        radius: 3
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
        // SECTION 2: EYE BREAK (20-20-20) & MASCOT MODE (UNIFIED DUAL-CARD)
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            radius: 12
            color: "#111420"
            border.color: "#1e2238"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                // --- LEFT: JEDA MATA 20-20-20 ---
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: "#065f46"
                        border.color: "#059669"
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "👁️"
                            font.pixelSize: 11
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Jeda 20-20-20"
                            color: "#f8fafc"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "Sisa " + IslandController.eyeBreakFormatted
                            color: "#34d399"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                    }

                    Rectangle {
                        width: 24
                        height: 24
                        radius: 12
                        color: eyeResetMouse.containsMouse ? "#047857" : "#064e3b"
                        border.color: "#059669"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "↺"
                            color: "#a7f3d0"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: eyeResetMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.resetEyeBreak()
                        }
                    }
                }

                // Vertical Divider Line
                Rectangle {
                    width: 1
                    height: 34
                    color: "#1e2538"
                }

                // --- RIGHT: MASKOT SANTAI TOGGLE ---
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8

                    Rectangle {
                        width: 26
                        height: 26
                        radius: 13
                        color: IslandController.mascotMode ? "#075985" : "#1e293b"
                        border.color: IslandController.mascotMode ? "#38bdf8" : "#334155"
                        border.width: 1
                        Text {
                            anchors.centerIn: parent
                            text: "👀"
                            font.pixelSize: 11
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Maskot Santai"
                            color: "#f8fafc"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Text {
                            text: IslandController.mascotMode ? "Mata Berkedip" : "Jam Digital"
                            color: IslandController.mascotMode ? "#38bdf8" : "#94a3b8"
                            font.pixelSize: 10
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        width: 32
                        height: 18
                        radius: 9
                        color: IslandController.mascotMode ? "#0284c7" : "#334155"
                        border.color: IslandController.mascotMode ? "#38bdf8" : "#475569"
                        border.width: 1

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            anchors.verticalCenter: parent.verticalCenter
                            x: IslandController.mascotMode ? parent.width - width - 3 : 3
                            color: "#ffffff"
                            Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.toggleMascotMode()
                        }
                    }
                }
            }
        }
    }
}
