import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 140
    implicitHeight: 28

    property real eyeScaleY: 1.0
    property real eyeOffsetX: 0.0
    property real eyeOffsetY: 0.0

    // Random blink timer
    Timer {
        id: blinkTimer
        interval: 3800
        running: true
        repeat: true
        onTriggered: {
            blinkAnimation.start()
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

    // Gentle ambient glow behind the eyes (Dynamic Notch style)
    Rectangle {
        anchors.centerIn: parent
        width: 76
        height: 22
        radius: 11
        color: "#19b8ff"
        opacity: mascotMouse.containsMouse ? 0.32 : 0.15
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    // The two eyes
    Row {
        id: eyesRow
        anchors.centerIn: parent
        spacing: 18

        transform: Translate {
            x: root.eyeOffsetX
            y: root.eyeOffsetY
            Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
            Behavior on y { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }
        }

        // Left Eye
        Rectangle {
            id: leftEye
            width: 8
            height: Math.max(1.5, 12 * root.eyeScaleY)
            radius: Math.min(width, height) / 2
            color: "#ffffff"
            transformOrigin: Item.Center
            scale: mascotMouse.containsMouse ? 1.15 : 1.0

            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

            // Highlight shine
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
            scale: mascotMouse.containsMouse ? 1.15 : 1.0

            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

            // Highlight shine
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPositionChanged: (mouse) => {
            // Smoothly look at cursor within -3.5px .. +3.5px
            var halfW = width / 2;
            var halfH = height / 2;
            root.eyeOffsetX = Math.max(-3.5, Math.min(3.5, ((mouse.x - halfW) / halfW) * 3.5));
            root.eyeOffsetY = Math.max(-2.0, Math.min(2.0, ((mouse.y - halfH) / halfH) * 2.0));
        }

        onExited: {
            root.eyeOffsetX = 0.0;
            root.eyeOffsetY = 0.0;
        }

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                IslandController.toggleMascotMode()
            } else {
                blinkAnimation.start()
                IslandController.toggleExpand()
            }
        }
    }
}
