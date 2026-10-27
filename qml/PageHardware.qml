import QtQuick
import QtQuick.Layouts

Item {
    id: root

    function tempColor(tempC) {
        if (tempC >= 80) return "#ef4444";
        if (tempC >= 62) return "#f59e0b";
        return "#22c55e";
    }

    function tempBgColor(tempC) {
        if (tempC >= 80) return "#3f151b";
        if (tempC >= 62) return "#382610";
        return "#112e21";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // =====================================================================
        // ROW 1: 3 PROPORTIONAL HARDWARE CARDS (1:1:1 EQUAL WIDTH, 86px HEIGHT)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            Layout.maximumHeight: 86
            spacing: 6

            // 1. CPU, SUHU & PROCESSOR TDP CARD
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                radius: 10
                color: "#12131c"
                border.color: IslandController.cpuTemp >= 80 ? "#ef4444" : "#24273a"
                border.width: 1
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    // Header: Title + Thermal Pill
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: "CPU & TDP"
                            color: "#e2e8f0"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            height: 16
                            radius: 8
                            implicitWidth: cpuTempTxt.implicitWidth + 10
                            color: root.tempBgColor(IslandController.cpuTemp)
                            border.color: root.tempColor(IslandController.cpuTemp)
                            border.width: 1

                            Text {
                                id: cpuTempTxt
                                anchors.centerIn: parent
                                text: IslandController.cpuTemp + "°C"
                                color: root.tempColor(IslandController.cpuTemp)
                                font.pixelSize: 9
                                font.weight: Font.ExtraBold
                            }
                        }
                    }

                    // Middle: Big TDP Wattage + Clock GHz
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: IslandController.cpuTdpText
                            color: "#38bdf8"
                            font.pixelSize: 13
                            font.weight: Font.ExtraBold
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: IslandController.cpuFreqText
                            color: "#94a3b8"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Progress Bar
                    Rectangle {
                        id: tdpBarBg
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: "#232638"

                        Rectangle {
                            width: Math.max(4, Math.min(tdpBarBg.width, tdpBarBg.width * IslandController.cpuTdpRatio))
                            height: parent.height
                            radius: parent.radius
                            color: IslandController.cpuTdpWatts >= 24 ? "#f59e0b" : "#38bdf8"
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                        }
                    }

                    // Footer: CPU Load % + Max TDP
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "CPU " + IslandController.cpuPercent + "%"
                            color: "#94a3b8"
                            font.pixelSize: 8
                            font.weight: Font.Medium
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Maks " + Math.round(IslandController.cpuTdpMaxWatts) + "W"
                            color: "#64748b"
                            font.pixelSize: 8
                        }
                    }
                }
            }

            // 2. GPU, SUHU & VRAM CARD
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                radius: 10
                color: "#12131c"
                border.color: IslandController.gpuTemp >= 80 ? "#ef4444" : "#24273a"
                border.width: 1
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    // Header: Title + Thermal Pill
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: "GPU & VRAM"
                            color: "#e2e8f0"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            height: 16
                            radius: 8
                            implicitWidth: gpuTempTxt.implicitWidth + 10
                            color: root.tempBgColor(IslandController.gpuTemp)
                            border.color: root.tempColor(IslandController.gpuTemp)
                            border.width: 1

                            Text {
                                id: gpuTempTxt
                                anchors.centerIn: parent
                                text: IslandController.gpuTemp + "°C"
                                color: root.tempColor(IslandController.gpuTemp)
                                font.pixelSize: 9
                                font.weight: Font.ExtraBold
                            }
                        }
                    }

                    // Middle: GPU Load % + GPU Clock MHz
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: IslandController.gpuPercent + "%"
                            color: "#a855f7"
                            font.pixelSize: 13
                            font.weight: Font.ExtraBold
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: IslandController.gpuFreqMhz > 0 ? (IslandController.gpuFreqMhz + " MHz") : "Radeon"
                            color: "#94a3b8"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Progress Bar
                    Rectangle {
                        id: vramBarBg
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: "#232638"

                        Rectangle {
                            width: Math.max(4, Math.min(vramBarBg.width, vramBarBg.width * (IslandController.vramPercent / 100.0)))
                            height: parent.height
                            radius: parent.radius
                            color: "#a855f7"
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                        }
                    }

                    // Footer: VRAM Readout
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "VRAM"
                            color: "#94a3b8"
                            font.pixelSize: 8
                            font.weight: Font.Medium
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: IslandController.vramText
                            color: "#64748b"
                            font.pixelSize: 8
                        }
                    }
                }
            }

            // 3. NVMe SSD, SUHU & DISK CARD
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                radius: 10
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    // Header: Title + Thermal Pill
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: "NVMe SSD"
                            color: "#e2e8f0"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            height: 16
                            radius: 8
                            implicitWidth: nvmeTempTxt.implicitWidth + 10
                            color: root.tempBgColor(IslandController.nvmeTemp)
                            border.color: root.tempColor(IslandController.nvmeTemp)
                            border.width: 1

                            Text {
                                id: nvmeTempTxt
                                anchors.centerIn: parent
                                text: IslandController.nvmeTemp + "°C"
                                color: root.tempColor(IslandController.nvmeTemp)
                                font.pixelSize: 9
                                font.weight: Font.ExtraBold
                            }
                        }
                    }

                    // Middle: Disk % + Used/Total GB
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: IslandController.diskPercent + "%"
                            color: "#22c55e"
                            font.pixelSize: 13
                            font.weight: Font.ExtraBold
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: IslandController.diskText
                            color: "#94a3b8"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Progress Bar
                    Rectangle {
                        id: diskBarBg
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: "#232638"

                        Rectangle {
                            width: Math.max(4, Math.min(diskBarBg.width, diskBarBg.width * (IslandController.diskPercent / 100.0)))
                            height: parent.height
                            radius: parent.radius
                            color: IslandController.diskPercent > 88 ? "#ef4444" : "#22c55e"
                            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutQuad } }
                        }
                    }

                    // Footer: RAM Usage
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "RAM"
                            color: "#94a3b8"
                            font.pixelSize: 8
                            font.weight: Font.Medium
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: IslandController.ramText
                            color: "#64748b"
                            font.pixelSize: 8
                        }
                    }
                }
            }
        }

        // =====================================================================
        // ROW 2: NETWORK TRAFFIC (1:1 LEFT) + PROCESSOR & TOP APP (1:1 RIGHT)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            Layout.maximumHeight: 42
            spacing: 6

            // Left Card: Network Traffic (Balanced Left Icon + Label, Right Speeds)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                radius: 10
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 7

                    Rectangle {
                        width: 26
                        height: 26
                        radius: 7
                        color: "#162032"
                        border.color: "#233554"
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            width: 14
                            height: 14
                            sourceSize.width: 14
                            sourceSize.height: 14
                            source: "file://" + AppConfig.assetsDir + "/network.svg"
                        }
                    }

                    ColumnLayout {
                        spacing: 1
                        Text {
                            text: "Jaringan"
                            color: "#e2e8f0"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                        Text {
                            text: "Live Trafik"
                            color: "#64748b"
                            font.pixelSize: 8
                        }
                    }

                    Item { Layout.fillWidth: true }

                    ColumnLayout {
                        spacing: 1
                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: "↓ " + IslandController.netDownSpeed
                            color: "#38bdf8"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                        Text {
                            Layout.alignment: Qt.AlignRight
                            text: "↑ " + IslandController.netUpSpeed
                            color: "#22c55e"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            // Right Card: CPU Model & Top Resource Culprit
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                radius: 10
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 7

                    Rectangle {
                        width: 26
                        height: 26
                        radius: 7
                        color: "#1b1d2e"
                        border.color: "#2b2f4a"
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            width: 14
                            height: 14
                            sourceSize.width: 14
                            sourceSize.height: 14
                            source: "file://" + AppConfig.assetsDir + "/cpu.svg"
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            text: IslandController.cpuModel
                            color: "#f8fafc"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "🔥 Top: " + IslandController.topProcess
                            color: "#94a3b8"
                            font.pixelSize: 9
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        // =====================================================================
        // ROW 3: INTERACTIVE POWER PROFILE & TDP MODE SWITCHER (36px HEIGHT)
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            Layout.maximumHeight: 36
            radius: 10
            color: "#12131c"
            border.color: "#24273a"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                spacing: 6

                Text {
                    text: "⚡ Mode TDP:"
                    color: "#cbd5e1"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                }

                Item { Layout.fillWidth: true }

                // 1. Power Saver Pill
                Rectangle {
                    height: 24
                    radius: 12
                    implicitWidth: 80
                    color: IslandController.powerProfile === "power-saver"
                           ? "#123524"
                           : (psMouse.containsMouse ? "#1e2233" : "#181a28")
                    border.color: IslandController.powerProfile === "power-saver" ? "#22c55e" : "#2a2e45"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "🍃 Hemat"
                        color: IslandController.powerProfile === "power-saver" ? "#4ade80" : "#94a3b8"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: psMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.setPowerProfile("power-saver")
                    }
                }

                // 2. Balanced Pill
                Rectangle {
                    height: 24
                    radius: 12
                    implicitWidth: 88
                    color: IslandController.powerProfile === "balanced"
                           ? "#102a42"
                           : (balMouse.containsMouse ? "#1e2233" : "#181a28")
                    border.color: IslandController.powerProfile === "balanced" ? "#38bdf8" : "#2a2e45"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "⚖️ Seimbang"
                        color: IslandController.powerProfile === "balanced" ? "#38bdf8" : "#94a3b8"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: balMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.setPowerProfile("balanced")
                    }
                }

                // 3. Performance Pill
                Rectangle {
                    height: 24
                    radius: 12
                    implicitWidth: 88
                    color: IslandController.powerProfile === "performance"
                           ? "#3b1722"
                           : (perfMouse.containsMouse ? "#1e2233" : "#181a28")
                    border.color: IslandController.powerProfile === "performance" ? "#f43f5e" : "#2a2e45"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "🚀 Performa"
                        color: IslandController.powerProfile === "performance" ? "#fb7185" : "#94a3b8"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: perfMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.setPowerProfile("performance")
                    }
                }
            }
        }
    }
}
