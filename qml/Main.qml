import QtQuick
import org.kde.layershell as LayerShell

Window {
    id: rootWindow
    opacity: IslandController.fullscreenActive ? 0.0 : 1.0
    visible: opacity > 0.0
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint

    Behavior on opacity { NumberAnimation { duration: 250 } }

    // Wayland Layer-Shell Configuration
    LayerShell.Window.layer: LayerShell.Window.LayerOverlay
    LayerShell.Window.anchors: LayerShell.Window.AnchorTop
    LayerShell.Window.margins.top: AppConfig.topMargin
    LayerShell.Window.exclusionZone: 0
    LayerShell.Window.scope: "dynamic-island"

    // The Wayland surface strictly conforms to the animated notch dimensions
    // allowing 100% click-through for every other area of the screen.
    width: island.visualWidth + 4
    height: island.height + 3

    Island {
        id: island
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
