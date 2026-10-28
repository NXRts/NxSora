import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // =====================================================================
        // SECTION 1: SPLIT WATER TRACKER + HOURLY HISTOGRAM CHART
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 102
            radius: 14
            color: "#111420"
            border.color: "#1e2238"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                // --- LEFT SIDE: WATER PROGRESS & CONTROLS ---
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5

                    // Title + Goal Percent Badge
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Rectangle {
                            width: 20
                            height: 20
                            radius: 6
                            color: "#0369a1"
                            Text {
                                anchors.centerIn: parent
                                text: "💧"
                                font.pixelSize: 10
                            }
                        }

                        Text {
                            text: "Water Reminder"
                            color: "#f8fafc"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            height: 18
                            radius: 9
                            color: IslandController.waterPercent >= 100 ? "#052e16" : "#082f49"
                            border.color: IslandController.waterPercent >= 100 ? "#22c55e" : "#0284c7"
                            border.width: 1
                            implicitWidth: percentText.implicitWidth + 12

                            Text {
                                id: percentText
                                anchors.centerIn: parent
                                text: IslandController.waterPercent >= 100
                                      ? "100% • Goal!"
                                      : (IslandController.waterPercent + "% Hari Ini")
                                color: IslandController.waterPercent >= 100 ? "#4ade80" : "#38bdf8"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }
                        }
                    }

                    // Big Volume Readout + Goal Clickable Pill
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Text {
                            text: (IslandController.waterIntake / 1000.0).toFixed(2)
                            color: "#ffffff"
                            font.pixelSize: 20
                            font.weight: Font.ExtraBold
                        }

                        Text {
                            text: "/ " + (IslandController.waterGoal / 1000.0).toFixed(1) + " L"
                            color: goalMouse.containsMouse ? "#38bdf8" : "#94a3b8"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            Layout.alignment: Qt.AlignBaseline

                            MouseArea {
                                id: goalMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: IslandController.cycleWaterGoal()
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    // Horizontal Gradient Progress Bar (.wbar)
                    Rectangle {
                        Layout.fillWidth: true
                        height: 5
                        radius: 2.5
                        color: "#1e293b"
                        clip: true

                        Rectangle {
                            width: parent.width * IslandController.waterProgressRatio
                            height: parent.height
                            radius: 2.5
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#66dbff" }
                                GradientStop { position: 1.0; color: "#2d6bff" }
                            }
                            Behavior on width {
                                NumberAnimation { duration: 380; easing.type: Easing.OutBack }
                            }
                        }
                    }

                    // Action Pills: [Drink +CupSize] [⚙ Ukuran Gelas] [↺ Reset]
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        // Drink Button
                        Rectangle {
                            height: 24
                            radius: 12
                            implicitWidth: drinkRow.implicitWidth + 16
                            color: drinkMouse.containsMouse ? "#0284c7" : "#0e4a86"
                            border.color: "#38bdf8"
                            border.width: 1

                            RowLayout {
                                id: drinkRow
                                anchors.centerIn: parent
                                spacing: 4
                                Text {
                                    text: "💧"
                                    font.pixelSize: 9
                                }
                                Text {
                                    text: "Drink +" + IslandController.waterCupSize + "ml"
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
                                onClicked: IslandController.drinkWater(IslandController.waterCupSize)
                            }
                        }

                        // Cup & Goal Settings Pill (Settings button)
                        Rectangle {
                            height: 24
                            radius: 12
                            implicitWidth: cupSetTxt.implicitWidth + 14
                            color: cupSetMouse.containsMouse ? "#283248" : "#1c2233"
                            border.color: "#334155"
                            border.width: 1

                            Text {
                                id: cupSetTxt
                                anchors.centerIn: parent
                                text: "⚙ Gelas/Target"
                                color: "#cbd5e1"
                                font.pixelSize: 9
                                font.weight: Font.DemiBold
                            }

                            MouseArea {
                                id: cupSetMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: (mouse) => {
                                    if (mouse.button === Qt.RightButton) {
                                        IslandController.cycleWaterGoal()
                                    } else {
                                        IslandController.cycleWaterCupSize()
                                    }
                                }
                            }
                        }

                        // Reset Button
                        Rectangle {
                            width: 24
                            height: 24
                            radius: 12
                            color: resetMouse.containsMouse ? "#334155" : "#1c2233"
                            border.color: "#334155"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "↺"
                                color: resetMouse.containsMouse ? "#f8fafc" : "#94a3b8"
                                font.pixelSize: 11
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
                }

                // Vertical Divider (x=208px divider)
                Rectangle {
                    width: 1
                    Layout.fillHeight: true
                    Layout.topMargin: 2
                    Layout.bottomMargin: 2
                    color: "#22293e"
                }

                // --- RIGHT SIDE: HOURLY HISTOGRAM CHART (09..16) ---
                ColumnLayout {
                    Layout.preferredWidth: 132
                    Layout.fillHeight: true
                    spacing: 3

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Grafik Per Jam"
                            color: "#94a3b8"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "ml"
                            color: "#64748b"
                            font.pixelSize: 9
                        }
                    }

                    // Chart Plot Container
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Horizontal Reference Grid Lines (500ml top, 250ml middle, 0ml bottom)
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: yAxisCol.left
                            anchors.rightMargin: 4
                            y: 2
                            height: 1
                            color: "#1e293b"
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: yAxisCol.left
                            anchors.rightMargin: 4
                            y: parent.height * 0.45
                            height: 1
                            color: "#1e293b"
                        }
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: yAxisCol.left
                            anchors.rightMargin: 4
                            y: parent.height - 14
                            height: 1
                            color: "#2b4c7e"
                        }

                        // 8 Vertical Hourly Bars (09..16)
                        Row {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 14
                            spacing: 6

                            Repeater {
                                model: IslandController.waterHourlyBars

                                Item {
                                    required property var modelData
                                    required property int index

                                    width: 7
                                    height: parent.height

                                    // Background Track Bar
                                    Rectangle {
                                        anchors.fill: parent
                                        radius: 3.5
                                        color: "#1a2032"
                                    }

                                    // Active Growing Bar (.wbar-col.wgrow)
                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.bottom: parent.bottom
                                        height: Math.max(modelData.ml > 0 ? 4 : 0, parent.height * modelData.ratio)
                                        radius: 3.5
                                        gradient: Gradient {
                                            orientation: Gradient.Vertical
                                            GradientStop {
                                                position: 0.0
                                                color: modelData.isCurrent ? "#66dbff" : "#38bdf8"
                                            }
                                            GradientStop {
                                                position: 1.0
                                                color: modelData.isCurrent ? "#2563eb" : "#1d4ed8"
                                            }
                                        }

                                        Behavior on height {
                                            NumberAnimation { duration: 420; easing.type: Easing.OutBack }
                                        }
                                    }
                                }
                            }
                        }

                        // X-Axis Labels (09, 12, 15)
                        Row {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            spacing: 25

                            Text { text: "09"; color: "#64748b"; font.pixelSize: 9 }
                            Text { text: "12"; color: "#64748b"; font.pixelSize: 9 }
                            Text { text: "15"; color: "#64748b"; font.pixelSize: 9 }
                        }

                        // Y-Axis Labels (500, 250, 0) on the right
                        Column {
                            id: yAxisCol
                            anchors.right: parent.right
                            anchors.top: parent.top
                            spacing: 13

                            Text { text: "500"; color: "#64748b"; font.pixelSize: 8 }
                            Text { text: "250"; color: "#64748b"; font.pixelSize: 8 }
                            Text { text: "0"; color: "#64748b"; font.pixelSize: 8 }
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
            Layout.preferredHeight: 56
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
                    height: 32
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
