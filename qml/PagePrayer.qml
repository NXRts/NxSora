import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // =====================================================================
        // ROW 1: HERO NEXT PRAYER READOUT (LEFT) + SUN ARC TRAJECTORY (RIGHT)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 106
            Layout.maximumHeight: 106
            spacing: 6

            // --- HERO NEXT PRAYER CARD (LEFT ~150px) ---
            Rectangle {
                Layout.preferredWidth: 150
                Layout.fillHeight: true
                radius: 10
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1
                clip: true

                // Glowing ambient accent behind text
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    height: parent.height * 0.9
                    radius: 30
                    color: IslandController.prayerIsDaytime ? "#f59e0b" : "#6366f1"
                    opacity: 0.12
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 3

                    // City Badge + Icon
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 5

                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            color: IslandController.prayerIsDaytime ? "#78350f" : "#1e1b4b"
                            border.color: IslandController.prayerIsDaytime ? "#f59e0b" : "#818cf8"
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                width: 10
                                height: 10
                                sourceSize: Qt.size(10, 10)
                                source: "file://" + AppConfig.assetsDir + "/" + (IslandController.prayerIsDaytime ? "sun.svg" : "crescent.svg")
                            }
                        }

                        Text {
                            text: IslandController.prayerCity
                            color: "#94a3b8"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Next Prayer Title
                    Text {
                        text: IslandController.prayerNextName
                        color: "#ffffff"
                        font.pixelSize: 17
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    // Prayer Exact Time
                    RowLayout {
                        spacing: 5
                        Text {
                            text: IslandController.prayerNextTime
                            color: IslandController.prayerIsDaytime ? "#fbbf24" : "#a5b4fc"
                            font.pixelSize: 14
                            font.weight: Font.ExtraBold
                        }
                        Text {
                            text: "WIB"
                            color: "#64748b"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            Layout.alignment: Qt.AlignBaseline
                        }
                    }

                    // Gentle Countdown
                    Rectangle {
                        height: 18
                        radius: 9
                        color: "#1e2438"
                        border.color: "#334155"
                        border.width: 1
                        implicitWidth: countdownLabel.implicitWidth + 12

                        Text {
                            id: countdownLabel
                            anchors.centerIn: parent
                            text: IslandController.prayerCountdown
                            color: "#38bdf8"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            // --- SUN ARC TRAJECTORY CANVAS CARD (RIGHT ~250px) ---
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 2

                    // Arc Card Header
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Lintasan Matahari (Sun Arc)"
                            color: "#cbd5e1"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: IslandController.prayerIsDaytime ? "Fase Siang" : "Fase Malam"
                            color: IslandController.prayerIsDaytime ? "#f59e0b" : "#818cf8"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }
                    }

                    // Interactive Sun Arc Canvas
                    Item {
                        id: arcContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Canvas {
                            id: arcCanvas
                            anchors.fill: parent

                            Connections {
                                target: IslandController
                                function onPrayerChanged() {
                                    arcCanvas.requestPaint();
                                }
                            }

                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();

                                var w = width;
                                var h = height;
                                var startX = 14;
                                var startY = h - 14;
                                var endX = w - 14;
                                var endY = h - 14;
                                var ctrlX = w / 2;
                                var ctrlY = -6;

                                // Draw Ground Horizon Line
                                ctx.strokeStyle = "#1e293b";
                                ctx.lineWidth = 1;
                                ctx.beginPath();
                                ctx.moveTo(startX, startY);
                                ctx.lineTo(endX, endY);
                                ctx.stroke();

                                // Draw Parabolic Trajectory Arc
                                ctx.strokeStyle = IslandController.prayerIsDaytime ? "rgba(245, 158, 11, 0.40)" : "rgba(99, 102, 241, 0.40)";
                                ctx.lineWidth = 2;
                                ctx.beginPath();
                                ctx.moveTo(startX, startY);
                                ctx.quadraticCurveTo(ctrlX, ctrlY, endX, endY);
                                ctx.stroke();

                                // Calculate position on quadratic curve for sunPosition [0.0 .. 1.0]
                                var t = Math.max(0.0, Math.min(1.0, IslandController.prayerSunPosition));
                                var sunX = Math.pow(1 - t, 2) * startX + 2 * (1 - t) * t * ctrlX + Math.pow(t, 2) * endX;
                                var sunY = Math.pow(1 - t, 2) * startY + 2 * (1 - t) * t * ctrlY + Math.pow(t, 2) * endY;

                                // Draw Sun Glow Halo
                                var radGrad = ctx.createRadialGradient(sunX, sunY, 2, sunX, sunY, 14);
                                if (IslandController.prayerIsDaytime) {
                                    radGrad.addColorStop(0.0, "rgba(251, 191, 36, 0.85)");
                                    radGrad.addColorStop(0.5, "rgba(245, 158, 11, 0.35)");
                                    radGrad.addColorStop(1.0, "rgba(245, 158, 11, 0.0)");
                                } else {
                                    radGrad.addColorStop(0.0, "rgba(165, 180, 252, 0.85)");
                                    radGrad.addColorStop(0.5, "rgba(99, 102, 241, 0.35)");
                                    radGrad.addColorStop(1.0, "rgba(99, 102, 241, 0.0)");
                                }
                                ctx.fillStyle = radGrad;
                                ctx.beginPath();
                                ctx.arc(sunX, sunY, 14, 0, 2 * Math.PI);
                                ctx.fill();

                                // Draw Core Orb
                                ctx.fillStyle = IslandController.prayerIsDaytime ? "#ffffff" : "#c7d2fe";
                                ctx.beginPath();
                                ctx.arc(sunX, sunY, 4.5, 0, 2 * Math.PI);
                                ctx.fill();
                            }
                        }

                        // Bottom Landmark Markers
                        RowLayout {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 0

                            Text {
                                text: "Terbit " + IslandController.prayerTerbit
                                color: "#64748b"
                                font.pixelSize: 8
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "Dzuhur " + IslandController.prayerDzuhur
                                color: "#64748b"
                                font.pixelSize: 8
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: "Tenggelam " + IslandController.prayerMaghrib
                                color: "#64748b"
                                font.pixelSize: 8
                            }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // ROW 2: 5-PRAYER TIMELINE & DAILY CHECKLIST TRACKER (HEIGHT: 56px)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            Layout.maximumHeight: 56
            spacing: 5

            Repeater {
                model: [
                    { name: "Subuh", key: "subuh", time: IslandController.prayerSubuh, idx: 0 },
                    { name: "Dzuhur", key: "dzuhur", time: IslandController.prayerDzuhur, idx: 1 },
                    { name: "Ashar", key: "ashar", time: IslandController.prayerAshar, idx: 2 },
                    { name: "Maghrib", key: "maghrib", time: IslandController.prayerMaghrib, idx: 3 },
                    { name: "Isya", key: "isya", time: IslandController.prayerIsya, idx: 4 }
                ]

                Rectangle {
                    required property var modelData
                    required property int index

                    readonly property bool isActive: (IslandController.prayerActiveIndex === modelData.idx)
                    readonly property bool isPast: (modelData.idx < IslandController.prayerActiveIndex)
                    readonly property bool isChecked: (IslandController.prayerChecklist && IslandController.prayerChecklist[modelData.key] === true)

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: isActive ? "#1e293b" : (isChecked ? "#064e3b" : "#12131c")
                    border.color: isActive ? "#38bdf8" : (isChecked ? "#059669" : "#24273a")
                    border.width: isActive ? 1.5 : 1
                    opacity: isPast && !isActive && !isChecked ? 0.55 : 1.0

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 1

                        // Prayer Name & Active Dot
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                text: modelData.name
                                color: isActive ? "#38bdf8" : (isChecked ? "#34d399" : "#cbd5e1")
                                font.pixelSize: 9
                                font.weight: isActive ? Font.Bold : Font.DemiBold
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            // Interactive Checkbox / Tick Box
                            Rectangle {
                                width: 14
                                height: 14
                                radius: 4
                                color: isChecked ? "#10b981" : "#1e2438"
                                border.color: isChecked ? "#34d399" : "#475569"
                                border.width: 1

                                Image {
                                    anchors.centerIn: parent
                                    width: 8
                                    height: 8
                                    sourceSize: Qt.size(8, 8)
                                    source: "file://" + AppConfig.assetsDir + "/check.svg"
                                    visible: isChecked
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        IslandController.setPrayerChecked(modelData.key, !isChecked);
                                    }
                                }
                            }
                        }

                        // Prayer Exact Time
                        Text {
                            text: modelData.time
                            color: isActive ? "#ffffff" : "#94a3b8"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }
                    }

                    // Click whole column to toggle checklist
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            IslandController.setPrayerChecked(modelData.key, !isChecked);
                        }
                    }
                }
            }
        }
    }
}
