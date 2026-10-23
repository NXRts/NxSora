import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

Rectangle {
    id: island
    color: "#07070a"
    border.color: islandMouse.containsMouse && !IslandController.isExpanded ? "#38bdf8" : "#23232c"
    border.width: 1

    // Dynamic dimensions driven by IslandController.state
    readonly property real targetWidth: {
        switch (IslandController.state) {
            case "idle": return 150;
            case "music": return 240;
            case "hud-volume": return 240;
            case "hud-battery": return 240;
            case "hud-notification": return 340;
            case "expanded-music": return 390;
            case "expanded-hub": return 400;
            default: return 150;
        }
    }

    readonly property real targetHeight: {
        switch (IslandController.state) {
            case "idle": return 34;
            case "music": return 36;
            case "hud-volume": return 38;
            case "hud-battery": return 38;
            case "hud-notification": return 64;
            case "expanded-music": return 185;
            case "expanded-hub": return 235;
            default: return 34;
        }
    }

    readonly property real targetRadius: {
        if (IslandController.isExpanded || IslandController.state === "hud-notification") {
            return 22;
        }
        return targetHeight / 2;
    }

    width: targetWidth
    height: targetHeight
    radius: targetRadius

    Behavior on width {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutBack
            easing.overshoot: 1.12
        }
    }

    Behavior on height {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutBack
            easing.overshoot: 1.12
        }
    }

    Behavior on radius {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.color {
        ColorAnimation { duration: 200 }
    }

    // Click handler on island background for expanding / wheel for volume
    MouseArea {
        id: islandMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: !IslandController.isExpanded ? Qt.PointingHandCursor : Qt.ArrowCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        
        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                IslandController.toggleExpand()
            } else if (!IslandController.isExpanded) {
                IslandController.toggleExpand()
            }
        }

        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                IslandController.changeVolume(0.03)
            } else if (wheel.angleDelta.y < 0) {
                IslandController.changeVolume(-0.03)
            }
        }
    }

    // Content container with opacity cross-fade
    Item {
        anchors.fill: parent
        clip: true

        // 1. Idle View
        CompactIdle {
            anchors.fill: parent
            visible: opacity > 0
            opacity: IslandController.state === "idle" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        // 2. Compact Music View
        CompactMusic {
            anchors.fill: parent
            visible: opacity > 0
            opacity: IslandController.state === "music" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        // 3. HUD Volume
        HudVolume {
            anchors.fill: parent
            visible: opacity > 0
            opacity: IslandController.state === "hud-volume" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        // 4. HUD Battery
        HudBattery {
            anchors.fill: parent
            visible: opacity > 0
            opacity: IslandController.state === "hud-battery" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        // 5. HUD Notification
        HudNotification {
            anchors.fill: parent
            visible: opacity > 0
            opacity: IslandController.state === "hud-notification" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        // 6. Expanded Music Card
        ExpandedMusic {
            anchors.fill: parent
            visible: opacity > 0
            opacity: IslandController.state === "expanded-music" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        // 7. Expanded Control Hub Card
        ExpandedHub {
            anchors.fill: parent
            visible: opacity > 0
            opacity: IslandController.state === "expanded-hub" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }
}
