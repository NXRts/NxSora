import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    // Reactive states from IslandController with safe fallbacks
    property bool volHudEnabled: IslandController ? (IslandController.getSetting("hud_volume_enabled") !== false) : true
    property bool battHudEnabled: IslandController ? (IslandController.getSetting("hud_battery_enabled") !== false) : true
    property bool btHudEnabled: IslandController ? (IslandController.getSetting("hud_bluetooth_enabled") !== false) : true
    property bool hwHudEnabled: IslandController ? (IslandController.getSetting("hud_hardware_enabled") !== false) : true
    property bool notifHudEnabled: IslandController ? (IslandController.getSetting("hud_notification_enabled") !== false) : true
    property bool netHudEnabled: IslandController ? (IslandController.getSetting("hud_network_enabled") !== false) : true
    property bool fsAutoHide: IslandController ? (IslandController.getSetting("fullscreen_autohide_enabled") !== false) : true
    property bool privacyDots: IslandController ? (IslandController.getSetting("privacy_dots_enabled") !== false) : true
    property bool eyeTracking: IslandController ? (IslandController.getSetting("eye_tracking_enabled") !== false) : true

    Connections {
        target: IslandController
        function onSettingsChanged() {
            if (!IslandController) return;
            root.volHudEnabled = IslandController.getSetting("hud_volume_enabled") !== false;
            root.battHudEnabled = IslandController.getSetting("hud_battery_enabled") !== false;
            root.btHudEnabled = IslandController.getSetting("hud_bluetooth_enabled") !== false;
            root.hwHudEnabled = IslandController.getSetting("hud_hardware_enabled") !== false;
            root.notifHudEnabled = IslandController.getSetting("hud_notification_enabled") !== false;
            root.netHudEnabled = IslandController.getSetting("hud_network_enabled") !== false;
            root.fsAutoHide = IslandController.getSetting("fullscreen_autohide_enabled") !== false;
            root.privacyDots = IslandController.getSetting("privacy_dots_enabled") !== false;
            root.eyeTracking = IslandController.getSetting("eye_tracking_enabled") !== false;
            if (settingsFlickable && IslandController.settingsScrollY > 0) {
                settingsFlickable.contentY = IslandController.settingsScrollY;
            }
        }
    }

    Flickable {
        id: settingsFlickable
        anchors.fill: parent
        anchors.rightMargin: 8
        contentWidth: width
        contentHeight: settingsCol.implicitHeight + 16
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            id: vertScrollBar
            policy: ScrollBar.AsNeeded
            width: 4
            anchors.right: parent.right
            background: Item {} // Transparent background to eliminate grey slab
            contentItem: Rectangle {
                implicitWidth: 4
                radius: 2
                color: vertScrollBar.pressed ? "#38bdf8" : (vertScrollBar.hovered ? "#64748b" : "#334155")
            }
        }

        ColumnLayout {
            id: settingsCol
            width: settingsFlickable.width
            spacing: 8

            // =================================================================
            // SECTION 1: SMART PEEK HUD OVERLAYS (310x60px)
            // =================================================================
            Text {
                text: "SMART PEEK & POP-UP HUD"
                color: "#64748b"
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.5
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 10
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1
                implicitHeight: hudGrid.implicitHeight + 16

                GridLayout {
                    id: hudGrid
                    anchors.fill: parent
                    anchors.margins: 10
                    columns: 2
                    rowSpacing: 8
                    columnSpacing: 12

                    // 1. Volume HUD
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/volume-high.svg"
                            }
                            Text {
                                text: "Volume HUD"
                                color: "#e2e8f0"
                                font.pixelSize: 11
                            }
                        }
                        Switch {
                            checked: root.volHudEnabled
                            onToggled: IslandController.setSetting("hud_volume_enabled", checked)
                        }
                    }

                    // 2. Battery HUD
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/battery.svg"
                            }
                            Text {
                                text: "Cas & Baterai HUD"
                                color: "#e2e8f0"
                                font.pixelSize: 11
                            }
                        }
                        Switch {
                            checked: root.battHudEnabled
                            onToggled: IslandController.setSetting("hud_battery_enabled", checked)
                        }
                    }

                    // 3. Bluetooth HUD
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/headphones.svg"
                            }
                            Text {
                                text: "Bluetooth & TWS"
                                color: "#e2e8f0"
                                font.pixelSize: 11
                            }
                        }
                        Switch {
                            checked: root.btHudEnabled
                            onToggled: IslandController.setSetting("hud_bluetooth_enabled", checked)
                        }
                    }

                    // 4. Hardware HUD (Caps Lock / Kecerahan)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/sun.svg"
                            }
                            Text {
                                text: "Caps & Kecerahan"
                                color: "#e2e8f0"
                                font.pixelSize: 11
                            }
                        }
                        Switch {
                            checked: root.hwHudEnabled
                            onToggled: IslandController.setSetting("hud_hardware_enabled", checked)
                        }
                    }

                    // 5. Notification HUD
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/bell.svg"
                            }
                            Text {
                                text: "Notifikasi Pop-up"
                                color: "#e2e8f0"
                                font.pixelSize: 11
                            }
                        }
                        Switch {
                            checked: root.notifHudEnabled
                            onToggled: IslandController.setSetting("hud_notification_enabled", checked)
                        }
                    }

                    // 6. Network / Wi-Fi HUD
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/network.svg"
                            }
                            Text {
                                text: "Wi-Fi & Jaringan HUD"
                                color: "#e2e8f0"
                                font.pixelSize: 11
                            }
                        }
                        Switch {
                            checked: root.netHudEnabled
                            onToggled: IslandController.setSetting("hud_network_enabled", checked)
                        }
                    }
                }
            }

            // =================================================================
            // SECTION 2: PRIVASI & PERILAKU SISTEM
            // =================================================================
            Text {
                text: "PRIVASI & PERILAKU SISTEM"
                color: "#64748b"
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.5
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 10
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1
                implicitHeight: privCol.implicitHeight + 16

                ColumnLayout {
                    id: privCol
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    // Fullscreen auto-hide
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            RowLayout {
                                spacing: 5
                                Image {
                                    width: 12
                                    height: 12
                                    sourceSize: Qt.size(12, 12)
                                    source: "file://" + AppConfig.assetsDir + "/gamepad.svg"
                                }
                                Text {
                                    text: "Fullscreen Auto-Hide"
                                    color: "#e2e8f0"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                            }
                            Text {
                                text: "Otomatis sembunyikan notch saat game atau video fullscreen berjalan"
                                color: "#94a3b8"
                                font.pixelSize: 9
                            }
                        }
                        Switch {
                            checked: root.fsAutoHide
                            onToggled: IslandController.setSetting("fullscreen_autohide_enabled", checked)
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#1e2130" }

                    // Privacy Dots
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            RowLayout {
                                spacing: 5
                                Image {
                                    width: 12
                                    height: 12
                                    sourceSize: Qt.size(12, 12)
                                    source: "file://" + AppConfig.assetsDir + "/shield.svg"
                                }
                                Text {
                                    text: "Privacy Dots (Kamera & Mikrofon)"
                                    color: "#e2e8f0"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                            }
                            Text {
                                text: "Tampilkan titik oranye (mic) & hijau (kamera) saat PipeWire aktif merekam"
                                color: "#94a3b8"
                                font.pixelSize: 9
                            }
                        }
                        Switch {
                            checked: root.privacyDots
                            onToggled: IslandController.setSetting("privacy_dots_enabled", checked)
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#1e2130" }

                    // Eye tracking
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            RowLayout {
                                spacing: 5
                                Image {
                                    width: 12
                                    height: 12
                                    sourceSize: Qt.size(12, 12)
                                    source: "file://" + AppConfig.assetsDir + "/eye.svg"
                                }
                                Text {
                                    text: "Mascot Eye-Tracking"
                                    color: "#e2e8f0"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                            }
                            Text {
                                text: "Mata maskot melirik halus mengikuti arah kursor mouse di sekitar notch"
                                color: "#94a3b8"
                                font.pixelSize: 9
                            }
                        }
                        Switch {
                            checked: root.eyeTracking
                            onToggled: IslandController.setSetting("eye_tracking_enabled", checked)
                        }
                    }
                }
            }

            // =================================================================
            // SECTION 2B: LOKASI TERPADU, CUACA & JADWAL SHOLAT (FASE 5)
            // =================================================================
            Text {
                text: "LOKASI TERPADU, CUACA & JADWAL SHOLAT (FASE 5)"
                color: "#64748b"
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.5
            }

            Rectangle {
                Layout.fillWidth: true
                radius: 10
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1
                implicitHeight: prayerSetCol.implicitHeight + 16

                ColumnLayout {
                    id: prayerSetCol
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // 1. Kartu Lokasi Aktif & Tombol Deteksi Otomatis
                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        radius: 8
                        color: "#181a27"
                        border.color: "#2a3147"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            Image {
                                Layout.preferredWidth: 16
                                Layout.preferredHeight: 16
                                sourceSize: Qt.size(16, 16)
                                source: "file://" + AppConfig.assetsDir + "/map-pin.svg"
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 1
                                Layout.alignment: Qt.AlignVCenter

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    spacing: 6

                                    Text {
                                        text: IslandController.locationCity || "Jakarta"
                                        color: "#f8fafc"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                        Layout.maximumWidth: 120
                                    }

                                    Rectangle {
                                        height: 13
                                        radius: 6.5
                                        color: "#0369a1"
                                        implicitWidth: coordTxt.implicitWidth + 8
                                        Layout.alignment: Qt.AlignVCenter

                                        Text {
                                            id: coordTxt
                                            anchors.centerIn: parent
                                            text: IslandController.locationLatitude + ", " + IslandController.locationLongitude
                                            color: "#e0f2fe"
                                            font.pixelSize: 8
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                Text {
                                    text: IslandController.locationRegion ? (IslandController.locationRegion + " · GMT+" + IslandController.locationTimezoneOffset) : "GMT+7"
                                    color: "#94a3b8"
                                    font.pixelSize: 8
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                }
                            }

                            // Tombol Deteksi Otomatis (1-klik)
                            Rectangle {
                                Layout.preferredWidth: 84
                                Layout.preferredHeight: 22
                                Layout.alignment: Qt.AlignVCenter
                                radius: 11
                                color: IslandController.locationIsDetecting ? "#0369a1" : (autoDetectMouse.containsMouse ? "#262f44" : "#1c2233")
                                border.color: "#38bdf8"
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Image {
                                        Layout.preferredWidth: 10
                                        Layout.preferredHeight: 10
                                        sourceSize: Qt.size(10, 10)
                                        source: "file://" + AppConfig.assetsDir + "/target.svg"
                                    }
                                    Text {
                                        text: IslandController.locationIsDetecting ? "Mencari..." : "Deteksi Auto"
                                        color: "#38bdf8"
                                        font.pixelSize: 8
                                        font.weight: Font.Bold
                                    }
                                }

                                MouseArea {
                                    id: autoDetectMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: IslandController.detectLocationAuto()
                                }
                            }
                        }
                    }

                    // 2. Kolom Pencarian Kota / Daerah (Open-Meteo Geocoding)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Rectangle {
                            Layout.fillWidth: true
                            height: 28
                            radius: 6
                            color: "#161824"
                            border.color: locSearchInput.activeFocus ? "#38bdf8" : "#2d334a"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 6
                                spacing: 6

                                Image {
                                    Layout.preferredWidth: 12
                                    Layout.preferredHeight: 12
                                    sourceSize: Qt.size(12, 12)
                                    source: "file://" + AppConfig.assetsDir + "/search.svg"
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                TextInput {
                                    id: locSearchInput
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    color: "#f1f5f9"
                                    font.pixelSize: 10
                                    selectByMouse: true
                                    clip: true
                                    verticalAlignment: TextInput.AlignVCenter

                                    Text {
                                        text: "Cari kota / kecamatan... (Enter)"
                                        color: "#64748b"
                                        font.pixelSize: 10
                                        visible: !locSearchInput.text && !locSearchInput.activeFocus
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    onAccepted: {
                                        if (text.trim().length >= 2) {
                                            IslandController.searchLocation(text.trim())
                                        }
                                    }
                                }

                                Rectangle {
                                    Layout.preferredWidth: 38
                                    Layout.preferredHeight: 18
                                    Layout.alignment: Qt.AlignVCenter
                                    radius: 4
                                    color: searchBtnMouse.containsMouse ? "#0284c7" : "#0369a1"
                                    visible: locSearchInput.text.trim().length >= 2

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Cari"
                                        color: "#ffffff"
                                        font.pixelSize: 9
                                        font.weight: Font.Bold
                                    }

                                    MouseArea {
                                        id: searchBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: IslandController.searchLocation(locSearchInput.text.trim())
                                    }
                                }
                            }
                        }

                        // Status message / Indicator
                        Text {
                            text: IslandController.locationStatusMessage
                            color: "#38bdf8"
                            font.pixelSize: 8
                            visible: IslandController.locationStatusMessage !== ""
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Search Results Dropdown List
                        ListView {
                            Layout.fillWidth: true
                            implicitHeight: Math.min(count * 32, 128)
                            visible: count > 0
                            clip: true
                            model: IslandController.locationSearchResults

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: 30
                                radius: 4
                                color: resMouse.containsMouse ? "#242a3e" : "#1a1d2c"
                                border.color: "#2a3147"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 6
                                    spacing: 6

                                    Image {
                                        Layout.preferredWidth: 10
                                        Layout.preferredHeight: 10
                                        sourceSize: Qt.size(10, 10)
                                        source: "file://" + AppConfig.assetsDir + "/map-pin.svg"
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        spacing: 0
                                        Layout.alignment: Qt.AlignVCenter

                                        Text {
                                            text: modelData.name || ""
                                            color: "#f8fafc"
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: (modelData.subtitle || "") + " (" + modelData.lat + ", " + modelData.lon + ")"
                                            color: "#94a3b8"
                                            font.pixelSize: 8
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 34
                                        Layout.preferredHeight: 18
                                        Layout.alignment: Qt.AlignVCenter
                                        radius: 3
                                        color: "#0369a1"

                                        Text {
                                            anchors.centerIn: parent
                                            text: "Pilih"
                                            color: "#e0f2fe"
                                            font.pixelSize: 9
                                            font.weight: Font.Bold
                                        }
                                    }
                                }

                                MouseArea {
                                    id: resMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        IslandController.selectLocationResult(index)
                                        locSearchInput.text = ""
                                    }
                                }
                            }
                        }
                    }

                    // 3. Preset Kota Populer (Horizontal scroll)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "Preset Kota Populer:"
                            color: "#94a3b8"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }

                        Flickable {
                            Layout.fillWidth: true
                            height: 24
                            contentWidth: cityRow.implicitWidth
                            clip: true

                            Row {
                                id: cityRow
                                spacing: 5

                                Repeater {
                                    model: ["Jakarta", "Bandung", "Surabaya", "Yogyakarta", "Semarang", "Medan", "Palembang", "Makassar", "Denpasar", "Banjarmasin"]

                                    Rectangle {
                                        required property string modelData
                                        readonly property bool isSelected: (IslandController.locationCity === modelData || IslandController.prayerCity === modelData)

                                        height: 22
                                        radius: 11
                                        color: isSelected ? "#0369a1" : (cityMouse.containsMouse ? "#27273a" : "#1a1b26")
                                        border.color: isSelected ? "#38bdf8" : "#334155"
                                        border.width: 1
                                        implicitWidth: cityLabel.implicitWidth + 14

                                        Text {
                                            id: cityLabel
                                            anchors.centerIn: parent
                                            text: modelData
                                            color: isSelected ? "#ffffff" : "#94a3b8"
                                            font.pixelSize: 10
                                            font.weight: isSelected ? Font.Bold : Font.Normal
                                        }

                                        MouseArea {
                                            id: cityMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: IslandController.searchLocation(modelData)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#1e2235"
                    }

                    // 4. Koreksi Waktu Ihtiath Sholat (+/- menit)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            spacing: 1
                            RowLayout {
                                spacing: 5
                                Image {
                                    Layout.preferredWidth: 12
                                    Layout.preferredHeight: 12
                                    sourceSize: Qt.size(12, 12)
                                    source: "file://" + AppConfig.assetsDir + "/timer.svg"
                                    Layout.alignment: Qt.AlignVCenter
                                }
                                Text {
                                    text: "Koreksi Waktu Sholat (Ihtiath)"
                                    color: "#e2e8f0"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                            }
                            Text {
                                text: "Geser menit untuk mencocokkan azan masjid lokal"
                                color: "#94a3b8"
                                font.pixelSize: 8
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                            }
                        }

                        RowLayout {
                            spacing: 4
                            Layout.alignment: Qt.AlignVCenter

                            Rectangle {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                radius: 4
                                color: minBtnMouse.containsMouse ? "#2d334a" : "#1e2235"
                                border.color: "#334155"
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: "–"
                                    color: "#e2e8f0"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                                MouseArea {
                                    id: minBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: IslandController.setLocationIhtiath(IslandController.locationIhtiathMinutes - 1)
                                }
                            }

                            Rectangle {
                                Layout.preferredHeight: 20
                                radius: 4
                                color: "#0f172a"
                                border.color: "#0284c7"
                                border.width: 1
                                implicitWidth: ihtiathTxt.implicitWidth + 10

                                Text {
                                    id: ihtiathTxt
                                    anchors.centerIn: parent
                                    text: (IslandController.locationIhtiathMinutes > 0 ? "+" : "") + IslandController.locationIhtiathMinutes + " mnt"
                                    color: "#38bdf8"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                }
                            }

                            Rectangle {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                radius: 4
                                color: plusBtnMouse.containsMouse ? "#2d334a" : "#1e2235"
                                border.color: "#334155"
                                border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: "+"
                                    color: "#e2e8f0"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                                MouseArea {
                                    id: plusBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: IslandController.setLocationIhtiath(IslandController.locationIhtiathMinutes + 1)
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: "#1e2235"
                    }

                    // Auto-Pause Music on Adzan
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            RowLayout {
                                spacing: 5
                                Image {
                                    width: 12
                                    height: 12
                                    sourceSize: Qt.size(12, 12)
                                    source: "file://" + AppConfig.assetsDir + "/music.svg"
                                }
                                Text {
                                    text: "Auto-Pause Pemutar Musik"
                                    color: "#e2e8f0"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                            }
                            Text {
                                text: "Otomatis jeda Spotify/lagu saat waktu adzan sholat tiba"
                                color: "#94a3b8"
                                font.pixelSize: 9
                            }
                        }
                        Switch {
                            checked: IslandController.prayerAutoPause
                            onToggled: IslandController.setPrayerAutoPause(checked)
                        }
                    }

                    // 10-Minute Heads-up Reminder
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            RowLayout {
                                spacing: 5
                                Image {
                                    width: 12
                                    height: 12
                                    sourceSize: Qt.size(12, 12)
                                    source: "file://" + AppConfig.assetsDir + "/crescent.svg"
                                }
                                Text {
                                    text: "Pengingat 10 Menit Sebelum Sholat"
                                    color: "#e2e8f0"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                            }
                            Text {
                                text: "Tampilkan heads-up kapsul tenang (310x36px) sebelum waktu sholat tiba"
                                color: "#94a3b8"
                                font.pixelSize: 9
                            }
                        }
                        Switch {
                            checked: IslandController.prayerReminderHeadsup
                            onToggled: IslandController.setPrayerReminderHeadsup(checked)
                        }
                    }

                    // At-Time Adzan Reminder
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            RowLayout {
                                spacing: 5
                                Image {
                                    width: 12
                                    height: 12
                                    sourceSize: Qt.size(12, 12)
                                    source: "file://" + AppConfig.assetsDir + "/bell.svg"
                                }
                                Text {
                                    text: "Pengingat Saat Waktu Azan Tiba"
                                    color: "#e2e8f0"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }
                            }
                            Text {
                                text: "Pop-up anggun di Dynamic Island saat masuk waktu sholat"
                                color: "#94a3b8"
                                font.pixelSize: 9
                            }
                        }
                        Switch {
                            checked: IslandController.prayerReminderAdzan
                            onToggled: IslandController.setPrayerReminderAdzan(checked)
                        }
                    }
                }
            }

            // =================================================================
            // SECTION 3: PENGUJIAN PEEK OVERLAYS & FASE 4 FITUR
            // =================================================================
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Tombol Uji Wi-Fi Peek
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 6
                    color: wifiTestMouse.containsMouse ? "#202d3e" : "#161b28"
                    border.color: wifiTestMouse.containsMouse ? "#38bdf8" : "#283348"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        Image {
                            width: 11
                            height: 11
                            sourceSize: Qt.size(11, 11)
                            source: "file://" + AppConfig.assetsDir + "/network.svg"
                        }
                        Text {
                            text: "Uji Wi-Fi Peek"
                            color: "#38bdf8"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: wifiTestMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.triggerWifiPeekDemo()
                    }
                }

                // Tombol Uji Baterai Lemah
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 6
                    color: battTestMouse.containsMouse ? "#3a221a" : "#221918"
                    border.color: battTestMouse.containsMouse ? "#f59e0b" : "#3c2824"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5
                        Image {
                            width: 11
                            height: 11
                            sourceSize: Qt.size(11, 11)
                            source: "file://" + AppConfig.assetsDir + "/battery.svg"
                        }
                        Text {
                            text: "Uji Baterai Lemah"
                            color: "#f59e0b"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: battTestMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.triggerLowBatteryDemo()
                    }
                }
            }

            // Uji Fitur Fase 4: Maskot & Cermin Kamera
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                // Uji Tidur Maskot
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 6
                    color: mSleepMouse.containsMouse ? "#26203a" : "#181726"
                    border.color: mSleepMouse.containsMouse ? "#a855f7" : "#2d2944"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Image {
                            width: 11
                            height: 11
                            sourceSize: Qt.size(11, 11)
                            source: "file://" + AppConfig.assetsDir + "/moon.svg"
                        }
                        Text {
                            text: "Tidur Maskot"
                            color: "#c084fc"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: mSleepMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.triggerMascotSleep()
                    }
                }

                // Uji Bangun / Sapa Maskot
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 6
                    color: mWakeMouse.containsMouse ? "#1c2b36" : "#141f28"
                    border.color: mWakeMouse.containsMouse ? "#38bdf8" : "#203444"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Image {
                            width: 11
                            height: 11
                            sourceSize: Qt.size(11, 11)
                            source: "file://" + AppConfig.assetsDir + "/sparkles.svg"
                        }
                        Text {
                            text: "Sapa Maskot"
                            color: "#38bdf8"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: mWakeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.triggerMascotWake()
                    }
                }

                // Uji Cermin Kamera
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 6
                    color: mCamMouse.containsMouse ? "#2a1e36" : "#1a1524"
                    border.color: mCamMouse.containsMouse ? "#f43f5e" : "#382436"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Image {
                            width: 11
                            height: 11
                            sourceSize: Qt.size(11, 11)
                            source: "file://" + AppConfig.assetsDir + "/video.svg"
                        }
                        Text {
                            text: "Cermin Kamera"
                            color: "#fb7185"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: mCamMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            IslandController.closeSettingsView()
                            IslandController.openCameraMirror()
                        }
                    }
                }
            }

            // SECTION 3B: AKSI & KONFIGURASI FILE
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Tombol Buka Config
                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    radius: 6
                    color: cfgBtnMouse.containsMouse ? "#272a3e" : "#181a26"
                    border.color: "#32374d"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Image {
                            width: 11
                            height: 11
                            sourceSize: Qt.size(11, 11)
                            source: "file://" + AppConfig.assetsDir + "/file-text.svg"
                        }
                        Text {
                            text: "Buka config.json"
                            color: "#38bdf8"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: cfgBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.openConfigFile()
                    }
                }

                // Tombol Reset Default
                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    radius: 6
                    color: rstBtnMouse.containsMouse ? "#3b171f" : "#181a26"
                    border.color: rstBtnMouse.containsMouse ? "#f43f5e" : "#32374d"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Image {
                            width: 11
                            height: 11
                            sourceSize: Qt.size(11, 11)
                            source: "file://" + AppConfig.assetsDir + "/refresh.svg"
                        }
                        Text {
                            text: "Reset ke Default"
                            color: rstBtnMouse.containsMouse ? "#f43f5e" : "#cbd5e1"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }

                    MouseArea {
                        id: rstBtnMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.resetSettings()
                    }
                }
            }

            // Version stamp
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "NxSora v0.1.0 • Neo-Sora Minimalist • Karya NXRts"
                color: "#475569"
                font.pixelSize: 9
            }
        }
    }
}
