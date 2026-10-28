import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property bool btPowered: IslandController.btAdapterPowered
    readonly property int connectedCount: IslandController.btConnectedCount
    readonly property bool hasActiveDev: IslandController.btDeviceConnected

    // Subtle floating animation for the left hero TWS earbuds
    property real floatY: 0.0
    SequentialAnimation on floatY {
        running: root.visible
        loops: Animation.Infinite
        NumberAnimation { to: -1.6; duration: 950; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.6; duration: 950; easing.type: Easing.InOutSine }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // =====================================================================
        // 1. LEFT CARD: BLUETOOTH ADAPTER & ACTIVE TWS HERO STATUS (132px)
        // =====================================================================
        Rectangle {
            Layout.preferredWidth: 132
            Layout.minimumWidth: 132
            Layout.maximumWidth: 132
            Layout.fillHeight: true
            radius: 12
            clip: true
            color: "#121217"
            border.color: root.hasActiveDev ? "#1e3a5f" : "#22222a"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 9
                spacing: 6

                // Top Row: Animated TWS Case Icon + Adapter Title & Status Pill
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 7

                    // Mini Animated TWS Case & Earbuds Badge
                    Rectangle {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        radius: 17
                        color: root.hasActiveDev ? "#0f2338" : "#181a24"
                        border.color: root.hasActiveDev ? "#5ec2ff" : "#334155"
                        border.width: 1.2

                        // Left Earbud Mini
                        Rectangle {
                            width: 5
                            height: 9
                            radius: 2.5
                            x: root.hasActiveDev ? 7 : 10
                            y: (root.hasActiveDev ? 5 : 9) + root.floatY
                            rotation: root.hasActiveDev ? -12 : -5
                            color: "#f8fafc"
                            border.color: "#5ec2ff"
                            border.width: 0.8
                            Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
                            Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
                        }

                        // Right Earbud Mini
                        Rectangle {
                            width: 5
                            height: 9
                            radius: 2.5
                            x: root.hasActiveDev ? 22 : 19
                            y: (root.hasActiveDev ? 5 : 9) - root.floatY
                            rotation: root.hasActiveDev ? 12 : 5
                            color: "#f8fafc"
                            border.color: "#5ec2ff"
                            border.width: 0.8
                            Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
                            Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutBack } }
                        }

                        // Charging Case Body Mini
                        Rectangle {
                            width: 18
                            height: 11
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: 17
                            topLeftRadius: 2
                            topRightRadius: 2
                            bottomLeftRadius: 5
                            bottomRightRadius: 5
                            color: "#e2e8f0"
                            border.color: "#94a3b8"
                            border.width: 0.8

                            // Case LED dot
                            Rectangle {
                                anchors.centerIn: parent
                                width: 3
                                height: 3
                                radius: 1.5
                                color: root.hasActiveDev ? "#33e07a" : "#f43f5e"
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.triggerTestBluetoothPeek()
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: "Bluetooth"
                            color: "#f8fafc"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            Layout.preferredWidth: statusLbl.implicitWidth + 10
                            Layout.preferredHeight: 15
                            radius: 7.5
                            color: !root.btPowered
                                   ? "#271820"
                                   : (root.connectedCount > 0 ? "#102a42" : "#1e293b")
                            border.color: !root.btPowered
                                          ? "#f43f5e"
                                          : (root.connectedCount > 0 ? "#5ec2ff" : "#475569")
                            border.width: 1

                            Text {
                                id: statusLbl
                                anchors.centerIn: parent
                                text: !root.btPowered
                                      ? "MATI"
                                      : (root.connectedCount > 0 ? (root.connectedCount + " AKTIF") : "SIAP")
                                color: !root.btPowered
                                       ? "#fda4af"
                                       : (root.connectedCount > 0 ? "#5ec2ff" : "#94a3b8")
                                font.pixelSize: 8
                                font.weight: Font.Bold
                            }
                        }
                    }
                }

                // Middle Status Box (Fills vertical space proportionally)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: "#171720"
                    border.color: root.hasActiveDev ? "#1e3a5f" : "#22222c"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 7
                        spacing: 3

                        Text {
                            Layout.fillWidth: true
                            text: root.hasActiveDev ? IslandController.btDeviceName : "Tidak Ada Koneksi"
                            color: root.hasActiveDev ? "#ffffff" : "#cbd5e1"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.hasActiveDev
                                  ? ("Baterai TWS · " + IslandController.btDeviceBattery + "%")
                                  : (IslandController.btDevicesList.length + " perangkat tersimpan")
                            color: root.hasActiveDev ? "#33e07a" : "#64748b"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }

                        Item { Layout.fillHeight: true }

                        // Battery / Readiness Progress Bar
                        Rectangle {
                            Layout.fillWidth: true
                            height: 5
                            radius: 2.5
                            color: "#252532"

                            Rectangle {
                                width: root.hasActiveDev
                                       ? parent.width * Math.min(1.0, Math.max(0.08, IslandController.btDeviceBattery / 100.0))
                                       : (root.btPowered ? parent.width * 0.25 : 0)
                                height: parent.height
                                radius: 2.5
                                color: root.hasActiveDev
                                       ? (IslandController.btDeviceBattery < 20 ? "#f43f5e" : "#5ec2ff")
                                       : "#475569"

                                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
                            }
                        }
                    }
                }

                // Bottom Action Buttons: [On/Off] [Setelan]
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    // Power Toggle Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 24
                        radius: 7
                        color: pwrMouse.containsMouse
                               ? "#243044"
                               : (root.btPowered ? "#152538" : "#1c1c26")
                        border.color: root.btPowered ? "#5ec2ff" : "#334155"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.btPowered ? "⏻ Aktif" : "⏻ Mati"
                            color: root.btPowered ? "#5ec2ff" : "#94a3b8"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: pwrMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.toggleBluetoothAdapter()
                        }
                    }

                    // Open KDE Bluetooth Settings
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 24
                        radius: 7
                        color: btSetMouse.containsMouse ? "#252534" : "#181822"
                        border.color: "#2d2d3c"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "⚙ Setelan"
                            color: "#cbd5e1"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }

                        MouseArea {
                            id: btSetMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.openBluetoothSettings()
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 2. RIGHT CARD: CONNECTED & PAIRED BLUETOOTH DEVICES LIST
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            radius: 12
            clip: true
            color: "#121217"
            border.color: "#22222a"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 9
                spacing: 6

                // Header Row (Fits cleanly inside 234px inner width)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        Layout.fillWidth: true
                        text: "Perangkat Bluetooth"
                        color: "#e2e8f0"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    // Test Peek Animation Button
                    Rectangle {
                        Layout.preferredWidth: peekBtnTxt.implicitWidth + 14
                        Layout.preferredHeight: 20
                        radius: 10
                        color: peekTestMouse.containsMouse ? "#1b334f" : "#132235"
                        border.color: "#29527a"
                        border.width: 1

                        Text {
                            id: peekBtnTxt
                            anchors.centerIn: parent
                            text: "🎬 Peek TWS"
                            color: "#5ec2ff"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: peekTestMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.triggerTestBluetoothPeek()
                        }
                    }
                }

                // Device ListView
                ListView {
                    id: btListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    model: IslandController.btDevicesList

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        width: btListView.width
                        height: 48
                        radius: 9
                        clip: true
                        color: Boolean(modelData.connected)
                               ? "#132030"
                               : (devCardMouse.containsMouse ? "#1c1c26" : "#171720")
                        border.color: Boolean(modelData.connected) ? "#5ec2ff" : "#252532"
                        border.width: Boolean(modelData.connected) ? 1.2 : 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 9
                            anchors.rightMargin: 9
                            spacing: 8

                            // 1. Device Category Icon Circle
                            Rectangle {
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 30
                                radius: 15
                                color: Boolean(modelData.connected) ? "#183350" : "#1e1e2a"
                                border.color: Boolean(modelData.connected) ? "#5ec2ff" : "#334155"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: {
                                        var cat = String(modelData.category || "device")
                                        if (cat === "tws" || cat === "headphones") return "🎧"
                                        if (cat === "speaker") return "🔊"
                                        if (cat === "mouse") return "🖱"
                                        if (cat === "keyboard") return "⌨"
                                        if (cat === "phone") return "📱"
                                        return "🔹"
                                    }
                                    font.pixelSize: 13
                                }
                            }

                            // 2. Device Name, Battery Pill & Status (Strictly bounded width)
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.preferredWidth: 1
                                Layout.minimumWidth: 0
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        text: String(modelData.name || "Bluetooth Device")
                                        color: "#f8fafc"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }

                                    // Battery Percentage Pill (shown if battery >= 0)
                                    Rectangle {
                                        visible: Number(modelData.battery) >= 0
                                        Layout.preferredWidth: batPillRow.implicitWidth + 8
                                        Layout.preferredHeight: 15
                                        radius: 7.5
                                        color: Number(modelData.battery) < 20 ? "#2e161d" : "#112822"
                                        border.color: Number(modelData.battery) < 20 ? "#f43f5e" : "#33e07a"
                                        border.width: 1

                                        RowLayout {
                                            id: batPillRow
                                            anchors.centerIn: parent
                                            spacing: 3
                                            Rectangle {
                                                width: 4
                                                height: 4
                                                radius: 2
                                                color: Number(modelData.battery) < 20 ? "#f43f5e" : "#33e07a"
                                            }
                                            Text {
                                                text: Number(modelData.battery) + "%"
                                                color: Number(modelData.battery) < 20 ? "#fda4af" : "#33e07a"
                                                font.pixelSize: 8
                                                font.weight: Font.Bold
                                            }
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4

                                    Rectangle {
                                        Layout.preferredWidth: 5
                                        Layout.preferredHeight: 5
                                        radius: 2.5
                                        color: Boolean(modelData.busy)
                                               ? "#facc15"
                                               : (Boolean(modelData.connected) ? "#33e07a" : "#64748b")
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        text: {
                                            if (Boolean(modelData.busy)) {
                                                return Boolean(modelData.connected) ? "Memutus..." : "Menyambungkan..."
                                            }
                                            if (Boolean(modelData.connected)) {
                                                return "Terkoneksi · Audio Aktif"
                                            }
                                            var cat = String(modelData.category || "device")
                                            var typeLabel = (cat === "tws") ? "TWS Audio" : ((cat === "headphones") ? "Headset" : "Perangkat")
                                            return "Tersimpan · " + typeLabel
                                        }
                                        color: Boolean(modelData.busy)
                                               ? "#facc15"
                                               : (Boolean(modelData.connected) ? "#5ec2ff" : "#64748b")
                                        font.pixelSize: 9
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }
                                }
                            }

                            // 3. Connect / Disconnect Action Button (Fixed crisp width, never clipped)
                            Rectangle {
                                Layout.preferredWidth: 62
                                Layout.minimumWidth: 62
                                Layout.preferredHeight: 24
                                radius: 7
                                color: {
                                    if (Boolean(modelData.connected)) {
                                        return actBtnMouse.containsMouse ? "#3b1924" : "#26141d"
                                    }
                                    return actBtnMouse.containsMouse ? "#1b3857" : "#14273d"
                                }
                                border.color: Boolean(modelData.connected) ? "#f43f5e" : "#5ec2ff"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: Boolean(modelData.busy)
                                          ? "..."
                                          : (Boolean(modelData.connected) ? "Putuskan" : "Sambung")
                                    color: Boolean(modelData.connected) ? "#fda4af" : "#5ec2ff"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                }

                                MouseArea {
                                    id: actBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        IslandController.toggleBluetoothDevice(String(modelData.address || ""))
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: devCardMouse
                            anchors.fill: parent
                            z: -1
                            hoverEnabled: true
                        }
                    }

                    // Empty state if no Bluetooth devices are paired
                    Text {
                        anchors.centerIn: parent
                        visible: btListView.count === 0
                        text: "Belum ada perangkat Bluetooth tersimpan"
                        color: "#64748b"
                        font.pixelSize: 10
                    }
                }
            }
        }
    }
}
