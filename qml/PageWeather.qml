import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // =====================================================================
        // SECTION 1: HERO WEATHER + METRICS (TOP HALF)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 88
            spacing: 6

            // --- HERO WEATHER CARD (LEFT) ---
            Rectangle {
                Layout.preferredWidth: 235
                Layout.fillHeight: true
                radius: 12
                color: "#111422"
                border.color: "#1e243a"
                border.width: 1
                clip: true

                // Subtle weather-adaptive glow background
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    height: parent.height * 0.9
                    radius: 30
                    color: IslandController.weatherIsDay ? "#0284c7" : "#4338ca"
                    opacity: 0.12
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    // Weather Icon with glow ring
                    Item {
                        width: 48
                        height: 48
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            anchors.centerIn: parent
                            width: 46
                            height: 46
                            radius: 23
                            color: IslandController.weatherIsDay ? "#0c2a42" : "#1e1b4b"
                            border.color: IslandController.weatherIsDay ? "#0284c7" : "#6366f1"
                            border.width: 1
                        }

                        Image {
                            anchors.centerIn: parent
                            width: 26
                            height: 26
                            sourceSize: Qt.size(26, 26)
                            source: "file://" + AppConfig.assetsDir + "/" + (IslandController.weatherIcon ? (IslandController.weatherIcon.indexOf(".svg") !== -1 ? IslandController.weatherIcon : (IslandController.weatherIcon + ".svg")) : "cloud.svg")
                        }
                    }

                    // Main Temperature & Condition
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        RowLayout {
                            spacing: 6
                            Text {
                                text: IslandController.weatherTemp || "27°C"
                                color: "#f8fafc"
                                font.pixelSize: 22
                                font.weight: Font.ExtraBold
                                font.letterSpacing: -0.5
                            }
                            Rectangle {
                                height: 16
                                radius: 8
                                color: "#1e243a"
                                implicitWidth: cityTxt.implicitWidth + 10
                                Text {
                                    id: cityTxt
                                    anchors.centerIn: parent
                                    text: IslandController.weatherCity || "Jakarta"
                                    color: "#38bdf8"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        Text {
                            text: IslandController.weatherCondition || "Sebagian Berawan"
                            color: "#cbd5e1"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: "Diperbarui: " + (IslandController.weatherLastUpdated || "Baru saja")
                            color: "#64748b"
                            font.pixelSize: 8
                        }
                    }
                }
            }

            // --- QUICK METRICS GRID (RIGHT) ---
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: "#111422"
                border.color: "#1e243a"
                border.width: 1

                GridLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    columns: 2
                    rowSpacing: 6
                    columnSpacing: 6

                    // 1. Kelembapan
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: "#151828"
                        border.color: "#222740"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 5
                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/droplet.svg"
                            }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Lembap"; color: "#64748b"; font.pixelSize: 8 }
                                Text { text: IslandController.weatherHumidityText || "70%"; color: "#38bdf8"; font.pixelSize: 9; font.weight: Font.Bold }
                            }
                        }
                    }

                    // 2. Angin
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: "#151828"
                        border.color: "#222740"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 5
                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/wind.svg"
                            }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Angin"; color: "#64748b"; font.pixelSize: 8 }
                                Text { text: IslandController.weatherWind || "10 km/h"; color: "#f8fafc"; font.pixelSize: 9; font.weight: Font.Bold }
                            }
                        }
                    }

                    // 3. Fase Waktu (Siang / Malam)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: "#151828"
                        border.color: "#222740"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 5
                            Image {
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + (IslandController.weatherIsDay ? "/sun.svg" : "/moon.svg")
                            }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Fase"; color: "#64748b"; font.pixelSize: 8 }
                                Text { text: IslandController.weatherIsDay ? "Siang" : "Malam"; color: IslandController.weatherIsDay ? "#facc15" : "#818cf8"; font.pixelSize: 9; font.weight: Font.Bold }
                            }
                        }
                    }

                    // 4. Refresh Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 8
                        color: rfMouse.containsMouse ? "#1e293b" : "#151828"
                        border.color: rfMouse.containsMouse ? "#38bdf8" : "#222740"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 5

                            Image {
                                id: rfIcon
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
                                font.pixelSize: 9
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
        // SECTION 2: DAY PROGRESS BAR & 6-HOUR FORECAST STRIP (BOTTOM HALF)
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 12
            color: "#111422"
            border.color: "#1e243a"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                // Top: Day Progress Header & Track
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Siklus 24 Jam"
                        color: "#94a3b8"
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 5
                        radius: 2.5
                        color: "#1e243a"

                        Rectangle {
                            width: parent.width * Math.min(1.0, Math.max(0.02, IslandController.dayProgressPercent / 100.0))
                            height: parent.height
                            radius: 2.5
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#0284c7" }
                                GradientStop { position: 1.0; color: "#38bdf8" }
                            }
                        }
                    }

                    Text {
                        text: IslandController.dayProgressText || "50%"
                        color: "#38bdf8"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                    }
                }

                // Bottom: 6-Hour Forecast Horizontal Strip
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    Repeater {
                        model: IslandController.weatherHourlyForecast

                        Rectangle {
                            required property var modelData
                            required property int index

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: hourMouse.containsMouse ? "#1c2236" : "#141726"
                            border.color: index === 0 ? "#0284c7" : (hourMouse.containsMouse ? "#38bdf8" : "#1e2338")
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
                                    width: 14
                                    height: 14
                                    sourceSize: Qt.size(14, 14)
                                    source: "file://" + AppConfig.assetsDir + "/" + (modelData.icon ? (modelData.icon.indexOf(".svg") !== -1 ? modelData.icon : (modelData.icon + ".svg")) : "cloud.svg")
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.temp || "--"
                                    color: "#f8fafc"
                                    font.pixelSize: 9
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
