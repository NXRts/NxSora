import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 140
    implicitHeight: 28

    property real eyeScaleY: 1.0
    property real eyeScaleX: 1.0
    property real eyeOffsetX: 0.0
    property real eyeOffsetY: 0.0
    property bool isSleeping: false
    property bool isWaving: false

    readonly property bool isHot: IslandController.cpuTemp >= 80
    readonly property bool isMusic: IslandController.mediaIsPlaying

    // 1. Inactivity Timer for Sleeping Mode (5 minutes without mouse activity)
    Timer {
        id: sleepTimer
        interval: 300000 // 5 minutes
        running: !root.isSleeping
        repeat: false
        onTriggered: {
            root.isSleeping = true
        }
    }

    // Connect to external controller triggers for testing sleep/wake
    Connections {
        target: IslandController
        function onMascotSleepTriggered() {
            root.isSleeping = true
        }
        function onMascotWakeTriggered() {
            wakeUp()
        }
    }

    function wakeUp() {
        if (root.isSleeping) {
            root.isSleeping = false
            root.isWaving = true
            waveTimer.restart()
            wakeAnimation.start()
        }
        sleepTimer.restart()
    }

    Timer {
        id: waveTimer
        interval: 2200
        repeat: false
        onTriggered: root.isWaving = false
    }

    // 2. Random Blink Timer (active only when awake)
    Timer {
        id: blinkTimer
        interval: 3800
        running: !root.isSleeping
        repeat: true
        onTriggered: {
            if (!root.isSleeping && !wakeAnimation.running) {
                blinkAnimation.start()
            }
            blinkTimer.interval = 3000 + Math.random() * 3000
        }
    }

    SequentialAnimation {
        id: blinkAnimation
        NumberAnimation {
            target: root
            property: "eyeScaleY"
            to: 0.1
            duration: 85
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

    // Wake Up Energetic Double-Blink & Pop Animation
    SequentialAnimation {
        id: wakeAnimation
        ParallelAnimation {
            NumberAnimation { target: root; property: "eyeScaleY"; to: 1.35; duration: 160; easing.type: Easing.OutBack }
            NumberAnimation { target: root; property: "eyeScaleX"; to: 1.25; duration: 160; easing.type: Easing.OutBack }
        }
        NumberAnimation { target: root; property: "eyeScaleY"; to: 0.1; duration: 80 }
        NumberAnimation { target: root; property: "eyeScaleY"; to: 1.1; duration: 120 }
        NumberAnimation { target: root; property: "eyeScaleY"; to: 0.1; duration: 70 }
        ParallelAnimation {
            NumberAnimation { target: root; property: "eyeScaleY"; to: 1.0; duration: 180; easing.type: Easing.OutBack }
            NumberAnimation { target: root; property: "eyeScaleX"; to: 1.0; duration: 180; easing.type: Easing.OutBack }
        }
    }

    // Gentle Breathing Animation when Sleeping
    SequentialAnimation {
        running: root.isSleeping
        loops: Animation.Infinite
        NumberAnimation {
            target: eyesRow
            property: "scale"
            to: 1.08
            duration: 1800
            easing.type: Easing.InOutSine
        }
        NumberAnimation {
            target: eyesRow
            property: "scale"
            to: 0.94
            duration: 1800
            easing.type: Easing.InOutSine
        }
    }

    // 3. Ambient Glow behind eyes (Adaptive: Cyan normally, Orange/Red on high CPU temp, Purple on music)
    Rectangle {
        anchors.centerIn: parent
        width: root.isWaving ? 88 : 76
        height: 22
        radius: 11
        color: root.isHot
               ? "#ef4444"
               : (root.isMusic
                  ? (IslandController.mediaAccentColor || "#c084fc")
                  : (root.isSleeping ? "#475569" : "#19b8ff"))
        opacity: root.isSleeping ? 0.08 : (mascotMouse.containsMouse || root.isWaving ? 0.40 : (root.isMusic ? 0.28 : 0.16))

        Behavior on color { ColorAnimation { duration: 300 } }
        Behavior on opacity { NumberAnimation { duration: 250 } }
        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
    }

    // 4. Floating "Z z z" Sleeping Indicators when Asleep
    Row {
        anchors.bottom: eyesRow.top
        anchors.horizontalCenter: eyesRow.horizontalCenter
        anchors.bottomMargin: 1
        spacing: 3
        visible: root.isSleeping
        opacity: root.isSleeping ? 0.85 : 0.0
        Behavior on opacity { NumberAnimation { duration: 400 } }

        Text {
            text: "z"
            color: "#94a3b8"
            font.pixelSize: 8
            font.weight: Font.Bold
            SequentialAnimation on y {
                running: root.isSleeping
                loops: Animation.Infinite
                NumberAnimation { from: 0; to: -4; duration: 1400; easing.type: Easing.InOutQuad }
                NumberAnimation { from: -4; to: 0; duration: 1400; easing.type: Easing.InOutQuad }
            }
        }
        Text {
            text: "Z"
            color: "#38bdf8"
            font.pixelSize: 10
            font.weight: Font.ExtraBold
            SequentialAnimation on y {
                running: root.isSleeping
                loops: Animation.Infinite
                NumberAnimation { from: -2; to: -6; duration: 1600; easing.type: Easing.InOutQuad }
                NumberAnimation { from: -6; to: -2; duration: 1600; easing.type: Easing.InOutQuad }
            }
        }
    }

    // 5. Thermal Sweat Bead when CPU >= 80°C
    Image {
        visible: root.isHot && !root.isSleeping
        anchors.left: eyesRow.right
        anchors.leftMargin: -2
        anchors.top: eyesRow.top
        anchors.topMargin: -4
        width: 9
        height: 9
        sourceSize: Qt.size(9, 9)
        source: "file://" + AppConfig.assetsDir + "/droplet.svg"

        SequentialAnimation on y {
            running: root.isHot && !root.isSleeping
            loops: Animation.Infinite
            NumberAnimation { from: -4; to: -1; duration: 500; easing.type: Easing.InOutQuad }
            NumberAnimation { from: -1; to: -4; duration: 500; easing.type: Easing.InOutQuad }
        }
    }

    // 6. Wave Hello Speech Badge
    Rectangle {
        visible: root.isWaving
        anchors.bottom: eyesRow.top
        anchors.bottomMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter
        height: 14
        radius: 7
        color: "#1e293b"
        border.color: "#38bdf8"
        border.width: 1
        implicitWidth: waveRow.implicitWidth + 12

        RowLayout {
            id: waveRow
            anchors.centerIn: parent
            spacing: 3

            Text {
                text: "Hai!"
                color: "#38bdf8"
                font.pixelSize: 8
                font.weight: Font.Bold
            }

            Image {
                width: 8
                height: 8
                sourceSize: Qt.size(8, 8)
                source: "file://" + AppConfig.assetsDir + "/sparkles.svg"
            }
        }
    }

    // 7. The Two Living Eyes
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
            width: 8 * root.eyeScaleX
            height: root.isSleeping ? 2.2 : Math.max(1.5, 12 * root.eyeScaleY)
            radius: Math.min(width, height) / 2
            color: root.isWaving ? "#7dd3fc" : "#ffffff"
            transformOrigin: Item.Center
            scale: (mascotMouse.containsMouse && !root.isSleeping) ? 1.15 : 1.0

            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 200 } }

            // Highlight shine
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 1.5
                width: 2.5
                height: 2.5
                radius: 1.25
                color: "#7dd3fc"
                visible: parent.height > 6 && !root.isSleeping
            }
        }

        // Right Eye
        Rectangle {
            id: rightEye
            width: 8 * root.eyeScaleX
            height: root.isSleeping ? 2.2 : Math.max(1.5, 12 * root.eyeScaleY)
            radius: Math.min(width, height) / 2
            color: root.isWaving ? "#7dd3fc" : "#ffffff"
            transformOrigin: Item.Center
            scale: (mascotMouse.containsMouse && !root.isSleeping) ? 1.15 : 1.0

            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
            Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 200 } }

            // Highlight shine
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 1.5
                width: 2.5
                height: 2.5
                radius: 1.25
                color: "#7dd3fc"
                visible: parent.height > 6 && !root.isSleeping
            }
        }
    }

    // 8. Interaction Handler
    MouseArea {
        id: mascotMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPositionChanged: (mouse) => {
            if (root.isSleeping) {
                root.wakeUp()
            } else {
                sleepTimer.restart()
            }

            // Smoothly look at cursor within -3.5px .. +3.5px
            var halfW = width / 2;
            var halfH = height / 2;
            root.eyeOffsetX = Math.max(-3.5, Math.min(3.5, ((mouse.x - halfW) / halfW) * 3.5));
            root.eyeOffsetY = Math.max(-2.0, Math.min(2.0, ((mouse.y - halfH) / halfH) * 2.0));
        }

        onEntered: {
            if (root.isSleeping) {
                root.wakeUp()
            }
        }

        onExited: {
            root.eyeOffsetX = 0.0;
            root.eyeOffsetY = 0.0;
        }

        onClicked: (mouse) => {
            if (root.isSleeping) {
                root.wakeUp()
                return
            }

            if (mouse.button === Qt.RightButton) {
                IslandController.toggleMascotMode()
            } else {
                blinkAnimation.start()
                IslandController.toggleExpand()
            }
        }
    }
}
