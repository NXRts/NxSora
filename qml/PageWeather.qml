import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // =====================================================================
        // ROW 1: HERO WEATHER (LEFT) + 4 COMPACT METRICS (RIGHT) (HEIGHT: 86px)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 86
            Layout.maximumHeight: 86
            spacing: 6

            // --- HERO WEATHER CARD (LEFT ~205px) ---
            Rectangle {
                Layout.preferredWidth: 205
                Layout.fillHeight: true
                radius: 10
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1
                clip: true

                // Gentle ambient glow
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    height: parent.height * 0.9
                    radius: 30
                    color: IslandController.weatherIsDay ? "#0284c7" : "#4338ca"
                    opacity: 0.10
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    // Weather Icon with circular badge
                    Rectangle {
                        width: 44
                        height: 44
                        radius: 22
                        color: IslandController.weatherIsDay ? "#0c2338" : "#1a1b38"
                        border.color: IslandController.weatherIsDay ? "#0284c7" : "#6366f1"
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            width: 24
                            height: 24
                            sourceSize: Qt.size(24, 24)
                            source: "file://" + AppConfig.assetsDir + "/" + (IslandController.weatherIcon ? (IslandController.weatherIcon.indexOf(".svg") !== -1 ? IslandController.weatherIcon : (IslandController.weatherIcon + ".svg")) : "cloud.svg")
                        }
                    }

                    // Main Temperature & Condition
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        RowLayout {
                            spacing: 5
                            Text {
                                text: IslandController.weatherTemp || "27°C"
                                color: "#f8fafc"
                                font.pixelSize: 20
                                font.weight: Font.ExtraBold
                                font.letterSpacing: -0.5
                            }
                            Rectangle {
                                height: 16
                                radius: 8
                                color: "#182338"
                                border.color: "#0284c7"
                                border.width: 1
                                implicitWidth: cityTxt.implicitWidth + 8
                                Text {
                                    id: cityTxt
                                    anchors.centerIn: parent
                                    text: IslandController.weatherCity || "Jakarta"
                                    color: "#38bdf8"
                                    font.pixelSize: 8
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        Text {
                            text: IslandController.weatherCondition || "Sebagian Berawan"
                            color: "#e2e8f0"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Update: " + (IslandController.weatherLastUpdated || "Baru saja")
                            color: "#64748b"
                            font.pixelSize: 8
                        }
                    }
                }
            }

            // --- QUICK METRICS GRID (RIGHT, 2x2 PILLS) ---
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 7
                    columns: 2
                    rowSpacing: 5
                    columnSpacing: 5

                    // 1. Kelembapan
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 7
                        color: "#181a26"
                        border.color: "#25283d"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 4

                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/droplet.svg"
                            }
                            Text { text: "Lembap"; color: "#94a3b8"; font.pixelSize: 8; font.weight: Font.Medium }
                            Item { Layout.fillWidth: true }
                            Text { text: IslandController.weatherHumidityText || "70%"; color: "#38bdf8"; font.pixelSize: 9; font.weight: Font.Bold }
                        }
                    }

                    // 2. Angin
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 7
                        color: "#181a26"
                        border.color: "#25283d"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 4

                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/wind.svg"
                            }
                            Text { text: "Angin"; color: "#94a3b8"; font.pixelSize: 8; font.weight: Font.Medium }
                            Item { Layout.fillWidth: true }
                            Text { text: IslandController.weatherWind || "10 km/h"; color: "#f8fafc"; font.pixelSize: 9; font.weight: Font.Bold }
                        }
                    }

                    // 3. Fase Hari
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 7
                        color: "#181a26"
                        border.color: "#25283d"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 4

                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + (IslandController.weatherIsDay ? "/sun.svg" : "/moon.svg")
                            }
                            Text { text: "Fase"; color: "#94a3b8"; font.pixelSize: 8; font.weight: Font.Medium }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: IslandController.weatherIsDay ? "Siang" : "Malam"
                                color: IslandController.weatherIsDay ? "#facc15" : "#818cf8"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }
                        }
                    }

                    // 4. Refresh Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 7
                        color: rfMouse.containsMouse ? "#20273c" : "#181a26"
                        border.color: rfMouse.containsMouse ? "#38bdf8" : "#25283d"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 4

                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/refresh.svg"

                                RotationAnimation on rotation {
                                    running: IslandController.weatherIsRefreshing
                                    loops: Animation.Infinite
                                    from: 0
                                    to: 360
                                    duration: 800
                                }
                            }

                            Text {
                                text: IslandController.weatherIsRefreshing ? "Memuat..." : "Refresh"
                                color: rfMouse.containsMouse ? "#38bdf8" : "#cbd5e1"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                            }
                        }

                        MouseArea {
                            id: rfMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.refreshWeather()
                        }
                    }
                }
            }
        }

        // =====================================================================
        // ROW 2: DAY PROGRESS & 6-HOUR HOURLY FORECAST (HEIGHT: 76px)
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            Layout.maximumHeight: 76
            radius: 10
            color: "#12131c"
            border.color: "#24273a"
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 7
                spacing: 5

                // Top: Day Progress Track
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 7

                    Text {
                        text: "Siklus Hari"
                        color: "#94a3b8"
                        font.pixelSize: 8
                        font.weight: Font.DemiBold
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: "#232638"

                        Rectangle {
                            width: parent.width * Math.min(1.0, Math.max(0.02, IslandController.dayProgressPercent / 100.0))
                            height: parent.height
                            radius: 2
                            color: "#38bdf8"
                        }
                    }

                    Text {
                        text: IslandController.dayProgressText || "50%"
                        color: "#38bdf8"
                        font.pixelSize: 8
                        font.weight: Font.Bold
                    }
                }

                // Bottom: 6-Hour Forecast Horizontal Strip
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5

                    Repeater {
                        model: IslandController.weatherHourlyForecast

                        Rectangle {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 6
                            color: index === 0 ? "#1c2538" : (hourMouse.containsMouse ? "#1c2236" : "#181a26")
                            border.color: index === 0 ? "#0284c7" : (hourMouse.containsMouse ? "#38bdf8" : "#25283d")
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.time || ""
                                    color: index === 0 ? "#38bdf8" : "#94a3b8"
                                    font.pixelSize: 8
                                    font.weight: Font.Bold
                                }

                                Image {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 13
                                    height: 13
                                    sourceSize: Qt.size(13, 13)
                                    source: "file://" + AppConfig.assetsDir + "/" + (modelData.icon ? (modelData.icon.indexOf(".svg") !== -1 ? modelData.icon : (modelData.icon + ".svg")) : "cloud.svg")
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.temp || "--"
                                    color: "#f8fafc"
                                    font.pixelSize: 8
                                    font.weight: Font.Bold
                                }
                            }

                            MouseArea {
                                id: hourMouse
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }
                    }
                }
            }
        }
    }
}
