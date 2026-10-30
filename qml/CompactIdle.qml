import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 150
    implicitHeight: 28

    // Live clock
    property string currentTime: "00:00"

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var date = new Date()
            var hours = date.getHours().toString().padStart(2, '0')
            var minutes = date.getMinutes().toString().padStart(2, '0')
            root.currentTime = hours + ":" + minutes
        }
    }

    // 1. Mascot Eyes Mode (Dynamic Notch Style)
    MascotEyes {
        anchors.fill: parent
        visible: opacity > 0
        opacity: IslandController.mascotMode ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    // 2. Closed Capsule Mode: [Circular Battery Ring] [Digital Clock] [Mini Wave / Battery %]
    RowLayout {
        anchors.centerIn: parent
        spacing: 8
        visible: opacity > 0
        opacity: IslandController.mascotMode ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        // LEFT: Circular Battery Conic Ring (15x15)
        Item {
            width: 15
            height: 15

            Canvas {
                id: closedBattRing
                anchors.fill: parent
                antialiasing: true

                property int pct: IslandController.batteryPercent
                property bool charging: IslandController.isCharging
                property int cpuT: IslandController.cpuTemp
                onPctChanged: requestPaint()
                onChargingChanged: requestPaint()
                onCpuTChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var cx = width / 2;
                    var cy = height / 2;
                    var r = 5.6;

                    // Background track ring
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, Math.PI * 2);
                    ctx.lineWidth = 2.2;
                    ctx.strokeStyle = "#1f2937";
                    ctx.stroke();

                    // Active battery conic arc (#33e07a green modern style)
                    var ratio = Math.max(0.08, Math.min(1.0, pct / 100.0));
                    var startAngle = -Math.PI / 2;
                    var endAngle = startAngle + (Math.PI * 2 * ratio);
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, startAngle, endAngle, false);
                    ctx.lineWidth = 2.2;
                    ctx.lineCap = "round";
                    ctx.strokeStyle = cpuT >= 80 ? "#ef4444" : (pct < 20 ? "#f59e0b" : "#33e07a");
                    ctx.stroke();
                }
            }

            // Center dot inside the battery ring
            Rectangle {
                anchors.centerIn: parent
                width: 4
                height: 4
                radius: 2
                color: IslandController.cpuTemp >= 80
                       ? "#ef4444"
                       : (IslandController.timerRunning
                          ? "#f59e0b"
                          : (IslandController.isCharging ? "#33e07a" : "#38bdf8"))

                SequentialAnimation on opacity {
                    running: IslandController.timerRunning || IslandController.cpuTemp >= 80
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.25; duration: 750 }
                    NumberAnimation { from: 0.25; to: 1.0; duration: 750 }
                }
            }
        }

        // CENTER: Digital Clock or Active Pomodoro Countdown
        Text {
            text: IslandController.timerRunning ? IslandController.timerFormatted : root.currentTime
            color: "#f8fafc"
            font.pixelSize: 12
            font.weight: Font.Bold
            font.family: "Inter, Noto Sans, sans-serif"
        }

        // KDE Virtual Desktop Indicator Pill (e.g. [ 1 ] with 1-click & wheel switch)
        Rectangle {
            visible: IslandController.workspaceCount > 1
            height: 14
            radius: 7
            implicitWidth: wsText.implicitWidth + 8
            color: wsMouse.containsMouse ? "#282a3d" : "#181a26"
            border.color: wsMouse.containsMouse ? "#38bdf8" : "#282b3d"
            border.width: 1

            Text {
                id: wsText
                anchors.centerIn: parent
                text: String(IslandController.currentWorkspaceIndex + 1)
                color: "#38bdf8"
                font.pixelSize: 8
                font.weight: Font.Bold
            }

            MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: IslandController.nextWorkspace()
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y > 0) {
                        IslandController.previousWorkspace()
                    } else if (wheel.angleDelta.y < 0) {
                        IslandController.nextWorkspace()
                    }
                }
            }
        }

        // Privacy Indicators (Fase 3): Green Dot (Camera), Orange Dot (Microphone)
        Row {
            spacing: 3
            Layout.alignment: Qt.AlignVCenter
            visible: (IslandController.camInUse || IslandController.micInUse)

            // Green Dot: Camera In-Use
            Rectangle {
                width: 5
                height: 5
                radius: 2.5
                color: "#22c55e"
                visible: IslandController.camInUse

                SequentialAnimation on opacity {
                    running: IslandController.camInUse
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.4; duration: 600 }
                    NumberAnimation { from: 0.4; to: 1.0; duration: 600 }
                }
            }

            // Orange Dot: Microphone In-Use
            Rectangle {
                width: 5
                height: 5
                radius: 2.5
                color: "#f97316"
                visible: IslandController.micInUse

                SequentialAnimation on opacity {
                    running: IslandController.micInUse
                    loops: Animation.Infinite
                    NumberAnimation { from: 1.0; to: 0.4; duration: 600 }
                    NumberAnimation { from: 0.4; to: 1.0; duration: 600 }
                }
            }
        }

        // RIGHT: Mini Sound Wave (when music/timer active) OR Battery % / High Temp
        Row {
            spacing: 2
            visible: IslandController.mediaIsPlaying || IslandController.timerRunning
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: 4
                Rectangle {
                    required property int index
                    width: 2
                    height: 8
                    radius: 1
                    anchors.verticalCenter: parent.verticalCenter
                    color: IslandController.timerRunning ? "#f59e0b" : (IslandController.mediaAccentColor || "#33e07a")

                    SequentialAnimation on height {
                        running: IslandController.mediaIsPlaying || IslandController.timerRunning
                        loops: Animation.Infinite
                        NumberAnimation {
                            to: (index % 2 === 0) ? 11 : 5
                            duration: 260 + index * 70
                            easing.type: Easing.InOutSine
                        }
                        NumberAnimation {
                            to: (index % 2 === 0) ? 4 : 10
                            duration: 260 + index * 70
                            easing.type: Easing.InOutSine
                        }
                    }
                }
            }
        }

        // Unread Notification Badge on Closed Capsule
        Rectangle {
            visible: !IslandController.mediaIsPlaying && !IslandController.timerRunning && IslandController.notifUnreadCount > 0
            width: unreadIdleRow.implicitWidth + 8
            height: 15
            radius: 7.5
            color: "#231d47"
            border.color: "#818cf8"
            border.width: 1

            RowLayout {
                id: unreadIdleRow
                anchors.centerIn: parent
                spacing: 2
                Rectangle {
                    width: 4
                    height: 4
                    radius: 2
                    color: "#818cf8"
                }
                Text {
                    text: String(IslandController.notifUnreadCount)
                    color: "#c7d2fe"
                    font.pixelSize: 9
                    font.weight: Font.Bold
                }
            }
        }

        Text {
            visible: !IslandController.mediaIsPlaying && !IslandController.timerRunning && IslandController.notifUnreadCount === 0 && (IslandController.hasBattery || IslandController.cpuTemp >= 78)
            text: IslandController.cpuTemp >= 78
                  ? (IslandController.cpuTemp + "°C")
                  : (IslandController.batteryPercent + "%")
            color: IslandController.cpuTemp >= 80
                   ? "#ef4444"
                   : (IslandController.cpuTemp >= 78
                      ? "#f59e0b"
                      : (IslandController.isCharging ? "#33e07a" : "#94a3b8"))
            font.pixelSize: 10
            font.weight: Font.DemiBold
        }
    }

    // Direct click handler when in Clock mode
    MouseArea {
        anchors.fill: parent
        enabled: !IslandController.mascotMode
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                IslandController.toggleMascotMode()
            } else {
                IslandController.toggleExpand()
            }
        }
    }
}
