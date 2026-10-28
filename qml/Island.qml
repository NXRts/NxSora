import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    id: island

    readonly property color islandColor: "#07070a"
    property bool isShelfDragNear: false
    property real gulpGlowOpacity: 0.0
    property real gulpScale: 1.0

    readonly property color currentAccentColor: {
        if (island.isShelfDragNear || island.gulpGlowOpacity > 0.05) {
            return "#2d5bff"
        }
        if (IslandController.state === "hud-bluetooth") {
            return IslandController.btDeviceConnected ? "#5ec2ff" : "#f43f5e"
        }
        if (IslandController.state === "hud-battery") {
            return IslandController.isCharging ? "#33e07a" : "#38bdf8"
        }
        if (IslandController.state === "music" || IslandController.isExpanded) {
            return IslandController.mediaAccentColor || "#38bdf8"
        }
        return "#38bdf8"
    }

    readonly property color islandBorderColor: {
        if (island.isShelfDragNear || island.gulpGlowOpacity > 0.05) {
            return "#38bdf8"
        }
        if (IslandController.state === "hud-bluetooth" || IslandController.state === "hud-battery") {
            return Qt.rgba(currentAccentColor.r, currentAccentColor.g, currentAccentColor.b, 0.65)
        }
        if (islandMouse.containsMouse && !IslandController.isExpanded) {
            return currentAccentColor
        }
        if (IslandController.mediaIsPlaying) {
            return Qt.rgba(currentAccentColor.r, currentAccentColor.g, currentAccentColor.b, 0.55)
        }
        return "#23232c"
    }

    readonly property real islandBorderWidth: (IslandController.mediaIsPlaying && !IslandController.isExpanded) || island.isShelfDragNear || IslandController.state === "hud-bluetooth" || IslandController.state === "hud-battery" ? 1.5 : 1.0

    // "Island Gulp" animation when files are dropped onto the Shelf
    SequentialAnimation {
        id: gulpAnimation
        ParallelAnimation {
            NumberAnimation { target: island; property: "gulpGlowOpacity"; to: 0.78; duration: 180; easing.type: Easing.OutQuad }
            NumberAnimation { target: island; property: "gulpScale"; to: 1.03; duration: 160; easing.type: Easing.OutBack }
        }
        ParallelAnimation {
            NumberAnimation { target: island; property: "gulpGlowOpacity"; to: 0.0; duration: 520; easing.type: Easing.InOutQuad }
            NumberAnimation { target: island; property: "gulpScale"; to: 1.0; duration: 380; easing.type: Easing.OutElastic }
        }
    }

    transform: Scale {
        origin.x: island.width / 2
        origin.y: 0
        xScale: island.gulpScale
        yScale: island.gulpScale
    }

    // Smart Hover Tracker & Auto-Collapse on Cursor Exit
    HoverHandler {
        id: islandHover
        onHoveredChanged: {
            if (!AppConfig.autoCollapseEnabled) return;
            if (IslandController.isExpanded && !IslandController.isPinned) {
                if (hovered) {
                    autoCollapseTimer.stop();
                } else {
                    autoCollapseTimer.restart();
                }
            }
        }
    }

    Timer {
        id: autoCollapseTimer
        interval: AppConfig.autoCollapseTimeout
        repeat: false
        onTriggered: {
            if (IslandController.isExpanded && !islandHover.hovered && !IslandController.isPinned) {
                // Do not collapse if the user is typing in a text field
                if (typeof rootWindow !== "undefined" && rootWindow && rootWindow.activeFocusItem && rootWindow.activeFocusItem.hasOwnProperty("text")) {
                    return;
                }
                IslandController.collapse();
            }
        }
    }

    Connections {
        target: IslandController
        function onIsExpandedChanged() {
            if (IslandController.isExpanded) {
                if (AppConfig.autoCollapseEnabled && !islandHover.hovered && !IslandController.isPinned) {
                    autoCollapseTimer.restart();
                } else {
                    autoCollapseTimer.stop();
                }
            } else {
                autoCollapseTimer.stop();
            }
        }
        function onIsPinnedChanged() {
            if (IslandController.isPinned) {
                autoCollapseTimer.stop();
            } else if (IslandController.isExpanded && !islandHover.hovered) {
                autoCollapseTimer.restart();
            }
        }
        function onShelfGulpTriggered() {
            gulpAnimation.restart();
        }
    }

    // Dimensions driven by IslandController.state (+ 520px wide split view in Synced Lyrics mode)
    readonly property real targetWidth: {
        switch (IslandController.state) {
            case "idle": return 150;
            case "music": return 230;
            case "hud-volume": return 230;
            case "hud-hardware": return 250;
            case "hud-battery": return 310;
            case "hud-bluetooth": return 310;
            case "hud-notification": return 330;
            case "expanded-music":
                return IslandController.lyricsModeActive ? 520 : 420;
            case "expanded-hub":
                if (IslandController.activeHubPage === 1 && IslandController.lyricsModeActive && IslandController.mediaHasTrack) {
                    return 520;
                }
                return 420;
            default: return 150;
        }
    }

    readonly property real targetHeight: {
        switch (IslandController.state) {
            case "idle": return 28;
            case "music": return 30;
            case "hud-volume": return 32;
            case "hud-hardware": return 36;
            case "hud-battery": return 60;
            case "hud-bluetooth": return 60;
            case "hud-notification": return 56;
            case "expanded-music": return 245;
            case "expanded-hub": return 245;
            default: return 28;
        }
    }

    readonly property real targetRadius: {
        if (IslandController.isExpanded
                || IslandController.state === "hud-notification"
                || IslandController.state === "hud-battery"
                || IslandController.state === "hud-bluetooth") {
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
            PathLine {
                x: 0; y: 0
            }
        }

        // Stroke Outline along ears, sides, and bottom
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
        opacity: {
            if (IslandController.state === "hud-bluetooth" || IslandController.state === "hud-battery") {
                return 0.36
            }
            return IslandController.mediaIsPlaying ? (IslandController.isExpanded ? 0.22 : 0.35) : 0.0
        }
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.45; color: Qt.rgba(island.currentAccentColor.r, island.currentAccentColor.g, island.currentAccentColor.b, 0.10) }
            GradientStop { position: 1.0; color: Qt.rgba(island.currentAccentColor.r, island.currentAccentColor.g, island.currentAccentColor.b, 0.42) }
        }
        Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    // 2B. Nusa "Island Gulp" Shelf Drop Glow Layer (#19b8ff -> #2d5bff -> #7b4bff)
    Rectangle {
        id: shelfGulpGlow
        anchors.fill: parent
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: island.cornerRadius
        bottomRightRadius: island.cornerRadius
        z: 1
        opacity: Math.max(island.gulpGlowOpacity, island.isShelfDragNear ? 0.45 : 0.0)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.rgba(0.10, 0.72, 1.0, 0.55) }
            GradientStop { position: 0.5; color: Qt.rgba(0.18, 0.36, 1.0, 0.65) }
            GradientStop { position: 1.0; color: Qt.rgba(0.48, 0.29, 1.0, 0.55) }
        }
        Behavior on opacity { NumberAnimation { duration: 220 } }
    }

    // 2C. Global Drag-Enter Detector on Compact Pill (auto-expands to Shelf when dragging files to top notch!)
    DropArea {
        anchors.fill: parent
        z: 15
        enabled: !IslandController.isExpanded || IslandController.activeHubPage !== 8

        onEntered: (drag) => {
            if (drag.hasUrls || drag.hasText) {
                drag.acceptProposedAction()
                island.isShelfDragNear = true
                IslandController.expandToShelf()
            }
        }
        onExited: {
            island.isShelfDragNear = false
        }
        onDropped: (drop) => {
            island.isShelfDragNear = false
            if (drop.hasUrls) {
                IslandController.addShelfFiles(drop.urls)
                drop.acceptProposedAction()
            } else if (drop.hasText) {
                IslandController.addShelfFiles(drop.text)
                drop.acceptProposedAction()
            }
        }
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
            if (IslandController.isExpanded) {
                wheel.accepted = true
                return
            }
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

        // 4. HUD Battery (Nusa 310x60px Charging Peek)
        HudBattery {
            anchors.fill: parent
            visible: opacity > 0
            opacity: IslandController.state === "hud-battery" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        // 4B. HUD Bluetooth Headphones Peek (Nusa 310x60px)
        HudBluetooth {
            anchors.fill: parent
            visible: opacity > 0
            opacity: IslandController.state === "hud-bluetooth" ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }

        // 4C. HUD Hardware (Brightness, Caps Lock, Mic Mute - 250x36px)
        HudHardware {
            anchors.fill: parent
            visible: opacity > 0
            opacity: IslandController.state === "hud-hardware" ? 1.0 : 0.0
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
