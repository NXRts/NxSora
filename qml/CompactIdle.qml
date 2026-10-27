import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 140
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

    // 1. Mascot Eyes Mode (Nusa Style)
    MascotEyes {
        anchors.fill: parent
        visible: opacity > 0
        opacity: IslandController.mascotMode ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    // 2. Standard Digital Clock Mode
    RowLayout {
        anchors.centerIn: parent
        spacing: 8
        visible: opacity > 0
        opacity: IslandController.mascotMode ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 250 } }

        // Small status / thermal indicator dot
        Rectangle {
            width: 7
            height: 7
            radius: 3.5
            color: IslandController.cpuTemp >= 80
                   ? "#ef4444"
                   : (IslandController.timerRunning ? "#f59e0b" : "#22c55e")

            SequentialAnimation on opacity {
                running: IslandController.timerRunning || IslandController.cpuTemp >= 80
                loops: Animation.Infinite
                NumberAnimation { from: 1.0; to: 0.3; duration: 800 }
                NumberAnimation { from: 0.3; to: 1.0; duration: 800 }
            }
        }

        // Clock or Active Timer
        Text {
            text: IslandController.timerRunning ? IslandController.timerFormatted : root.currentTime
            color: "#f8fafc"
            font.pixelSize: 12
            font.weight: Font.DemiBold
            font.family: "Inter, Noto Sans, sans-serif"
        }

        // Battery % (or high CPU Temp badge when CPU >= 78°C)
        Text {
            text: IslandController.cpuTemp >= 78
                  ? (IslandController.cpuTemp + "°C")
                  : (IslandController.batteryPercent + "%")
            color: IslandController.cpuTemp >= 80
                   ? "#ef4444"
                   : (IslandController.cpuTemp >= 78
                      ? "#f59e0b"
                      : (IslandController.isCharging ? "#22c55e" : "#94a3b8"))
            font.pixelSize: 10
            font.weight: Font.Medium
            visible: IslandController.hasBattery || IslandController.cpuTemp >= 78
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
