import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 150
    implicitHeight: 34

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

    RowLayout {
        anchors.centerIn: parent
        spacing: 8

        // Small indicator dot
        Rectangle {
            width: 7
            height: 7
            radius: 3.5
            color: IslandController.timerRunning ? "#f59e0b" : "#22c55e"

            SequentialAnimation on opacity {
                running: IslandController.timerRunning
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

        // Tiny battery or dot
        Text {
            text: IslandController.batteryPercent + "%"
            color: IslandController.isCharging ? "#22c55e" : "#94a3b8"
            font.pixelSize: 10
            font.weight: Font.Medium
            visible: IslandController.hasBattery
        }
    }
}
