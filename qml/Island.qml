import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    id: island

    readonly property color islandColor: "#07070a"

    readonly property color currentAccentColor: {
        if (IslandController.state === "music" || IslandController.isExpanded) {
            return IslandController.mediaAccentColor || "#38bdf8"
        }
        return "#38bdf8"
    }

    readonly property color islandBorderColor: {
        if (islandMouse.containsMouse && !IslandController.isExpanded) {
            return currentAccentColor
        }
        if (IslandController.mediaIsPlaying) {
            return Qt.rgba(currentAccentColor.r, currentAccentColor.g, currentAccentColor.b, 0.55)
        }
        return "#23232c"
    }

    readonly property real islandBorderWidth: IslandController.mediaIsPlaying && !IslandController.isExpanded ? 1.5 : 1.0

    // Dimensions driven by IslandController.state
    readonly property real targetWidth: {
        switch (IslandController.state) {
            case "idle": return 140;
            case "music": return 230;
            case "hud-volume": return 230;
            case "hud-battery": return 230;
            case "hud-notification": return 330;
            case "expanded-music": return 420;
            case "expanded-hub": return 420;
            default: return 140;
        }
    }

    readonly property real targetHeight: {
        switch (IslandController.state) {
            case "idle": return 28;
            case "music": return 30;
            case "hud-volume": return 32;
            case "hud-battery": return 32;
            case "hud-notification": return 56;
            case "expanded-music": return 245;
            case "expanded-hub": return 245;
            default: return 28;
        }
    }

    readonly property real targetRadius: {
        if (IslandController.isExpanded || IslandController.state === "hud-notification") {
            return 20;
        }
        return targetHeight / 2;
    }

    readonly property real earRadius: 12
    readonly property real visualWidth: width + earRadius * 2

    width: targetWidth
    height: targetHeight
    property real cornerRadius: targetRadius

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

    Behavior on cornerRadius {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    // 1. Sleek Notch Shape with Nusa-Style Concave Ears & Rounded Bottom
    Shape {
        id: notchShape
        x: -island.earRadius
        y: 0
        width: island.width + island.earRadius * 2
        height: island.height
        z: 0

        layer.enabled: true
        layer.samples: 4

        // Fill Solid Background
        ShapePath {
            strokeColor: "transparent"
            fillColor: island.islandColor

            startX: 0; startY: 0

            // Left ear concave curve into notch left edge
            PathArc {
                x: island.earRadius; y: island.earRadius
                radiusX: island.earRadius; radiusY: island.earRadius
                direction: PathArc.Clockwise
            }

            // Down the left edge
            PathLine {
                x: island.earRadius
                y: island.height - island.cornerRadius
            }

            // Bottom-left rounded corner
            PathArc {
                x: island.earRadius + island.cornerRadius
                y: island.height
                radiusX: island.cornerRadius; radiusY: island.cornerRadius
                direction: PathArc.Counterclockwise
            }

            // Across the bottom edge
            PathLine {
                x: island.earRadius + island.width - island.cornerRadius
                y: island.height
            }

            // Bottom-right rounded corner
            PathArc {
                x: island.earRadius + island.width
                y: island.height - island.cornerRadius
                radiusX: island.cornerRadius; radiusY: island.cornerRadius
                direction: PathArc.Counterclockwise
            }

            // Up the right edge
            PathLine {
                x: island.earRadius + island.width
                y: island.earRadius
            }

            // Right ear concave curve into top panel
            PathArc {
                x: island.earRadius * 2 + island.width
                y: 0
                radiusX: island.earRadius; radiusY: island.earRadius
                direction: PathArc.Clockwise
            }

            // Top edge closing the fill polygon
            PathLine {
                x: 0; y: 0
            }
        }

        // Stroke Outline along ears, sides, and bottom (top edge remains open for flush attachment!)
        ShapePath {
            strokeColor: island.islandBorderColor
            strokeWidth: island.islandBorderWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            startX: 0; startY: 0

            PathArc {
                x: island.earRadius; y: island.earRadius
                radiusX: island.earRadius; radiusY: island.earRadius
                direction: PathArc.Clockwise
            }
            PathLine {
                x: island.earRadius
                y: island.height - island.cornerRadius
            }
            PathArc {
                x: island.earRadius + island.cornerRadius
                y: island.height
                radiusX: island.cornerRadius; radiusY: island.cornerRadius
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: island.earRadius + island.width - island.cornerRadius
                y: island.height
            }
            PathArc {
                x: island.earRadius + island.width
                y: island.height - island.cornerRadius
                radiusX: island.cornerRadius; radiusY: island.cornerRadius
                direction: PathArc.Counterclockwise
            }
            PathLine {
                x: island.earRadius + island.width
                y: island.earRadius
            }
            PathArc {
                x: island.earRadius * 2 + island.width
                y: 0
                radiusX: island.earRadius; radiusY: island.earRadius
                direction: PathArc.Clockwise
            }
        }
    }

    // 2. Ambient Music Glow Layer (Poni & Nusa Inspired)
    Rectangle {
        id: ambientGlow
        anchors.fill: parent
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: island.cornerRadius
        bottomRightRadius: island.cornerRadius
        color: "transparent"
        z: 1
        opacity: IslandController.mediaIsPlaying ? (IslandController.isExpanded ? 0.20 : 0.35) : 0.0
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.45; color: Qt.rgba(island.currentAccentColor.r, island.currentAccentColor.g, island.currentAccentColor.b, 0.10) }
            GradientStop { position: 1.0; color: Qt.rgba(island.currentAccentColor.r, island.currentAccentColor.g, island.currentAccentColor.b, 0.42) }
        }
        Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    // 3. Click handler on island background for expanding / wheel for volume
    MouseArea {
        id: islandMouse
        anchors.fill: parent
        z: 2
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

    // 4. Content container with opacity cross-fade
    Item {
        anchors.fill: parent
        clip: true
        z: 3

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

        // 6. Expanded Multi-Page Control Hub
        ExpandedHub {
            anchors.fill: parent
            visible: opacity > 0
            opacity: (IslandController.state === "expanded-hub" || IslandController.state === "expanded-music") ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }
}
