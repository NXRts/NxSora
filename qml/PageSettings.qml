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
            root.fsAutoHide = IslandController.getSetting("fullscreen_autohide_enabled") !== false;
            root.privacyDots = IslandController.getSetting("privacy_dots_enabled") !== false;
            root.eyeTracking = IslandController.getSetting("eye_tracking_enabled") !== false;
        }
    }

    Flickable {
        anchors.fill: parent
        contentWidth: width
        contentHeight: settingsCol.implicitHeight + 10
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: settingsCol
            width: parent.width
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
            // SECTION 3: AKSI & KONFIGURASI FILE
            // =================================================================
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
