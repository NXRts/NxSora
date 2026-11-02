import QtQuick

Window {
    id: rootWindow
    visible: true
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool

    // The Windows surface strictly conforms to the animated notch dimensions
    width: island.visualWidth + 4
    height: island.height + 3

    // Dynamically centered at top of active screen with top margin offset
    x: Screen.virtualX + Math.round((Screen.width - width) / 2)
    y: Screen.virtualY + ((typeof IslandController !== "undefined" && IslandController) ? IslandController.topMargin : AppConfig.topMargin)

    Island {
        id: island
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
    }
}

