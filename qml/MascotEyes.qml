import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 150
    implicitHeight: 34

    property real eyeScaleY: 1.0

    // Random blink timer
    Timer {
        id: blinkTimer
        interval: 3800
        running: true
        repeat: true
        onTriggered: {
            blinkAnimation.start()
            // Randomize next interval between 3s and 6s
            blinkTimer.interval = 3000 + Math.random() * 3000
        }
    }

    SequentialAnimation {
        id: blinkAnimation
        NumberAnimation {
            target: root
            property: "eyeScaleY"
            to: 0.1
            duration: 90
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: root
            property: "eyeScaleY"
            to: 1.0
            duration: 130
            easing.type: Easing.OutQuad
        }
    }

    // Gentle ambient glow behind the eyes
    Rectangle {
        anchors.centerIn: parent
        width: 70
        height: 24
        radius: 12
        color: "#19b8ff"
        opacity: mascotMouse.containsMouse ? 0.35 : 0.18
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    // The two eyes
    Row {
        anchors.centerIn: parent
        spacing: 16

        // Left Eye
        Rectangle {
            id: leftEye
            width: 8
            height: Math.max(1.5, 12 * root.eyeScaleY)
            radius: Math.min(width, height) / 2
            color: "#ffffff"
            transformOrigin: Item.Center
            scale: mascotMouse.containsMouse ? 1.18 : 1.0

            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

            // Eye reflection highlight
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 1.5
                width: 2.5
                height: 2.5
                radius: 1.25
                color: "#7dd3fc"
                visible: parent.height > 6
            }
        }

        // Right Eye
        Rectangle {
            id: rightEye
            width: 8
            height: Math.max(1.5, 12 * root.eyeScaleY)
            radius: Math.min(width, height) / 2
            color: "#ffffff"
            transformOrigin: Item.Center
            scale: mascotMouse.containsMouse ? 1.18 : 1.0

            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

            // Eye reflection highlight
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 1.5
                width: 2.5
                height: 2.5
                radius: 1.25
                color: "#7dd3fc"
                visible: parent.height > 6
            }
        }
    }

    MouseArea {
        id: mascotMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            blinkAnimation.start()
        }
    }
}
