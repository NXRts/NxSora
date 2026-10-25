import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    implicitWidth: 420
    implicitHeight: 245

    // Current page titles
    readonly property var pageTitles: [
        "Sistem & Monitoring",
        "Pemutar Musik",
        "Pintasan Cepat",
        "Jaringan & Info",
        "Kesehatan & Air",
        "Daftar Tugas (To-Do)"
    ]

    Connections {
        target: IslandController
        function onActiveHubPageChanged() {
            if (swipeView) swipeView.currentIndex = IslandController.activeHubPage
        }
        function onIsExpandedChanged() {
            if (swipeView && IslandController.isExpanded) {
                swipeView.currentIndex = IslandController.activeHubPage
            }
        }
    }

    Component.onCompleted: {
        if (swipeView) swipeView.currentIndex = IslandController.activeHubPage
    }

    function goToPrevPage() {
        if (swipeView.currentIndex > 0)
            swipeView.currentIndex--
        else
            swipeView.currentIndex = swipeView.count - 1
    }

    function goToNextPage() {
        if (swipeView.currentIndex < swipeView.count - 1)
            swipeView.currentIndex++
        else
            swipeView.currentIndex = 0
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // =====================================================================
        // =====================================================================
        // HEADER: [ < | > ] [Title + Page Indicator Dots] [Close Button]
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Navigation Arrows Capsule (< >)
            Rectangle {
                id: navCapsule
                width: 62
                height: 28
                radius: 14
                color: "#181a26"
                border.color: "#282b3d"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // < Button
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Image {
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            source: "file://" + AppConfig.assetsDir + "/chevron-left.svg"
                            opacity: prevMouse.containsMouse ? 1.0 : 0.7
                        }

                        MouseArea {
                            id: prevMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.goToPrevPage()
                        }
                    }

                    // Divider
                    Rectangle {
                        width: 1
                        height: 14
                        color: "#282b3d"
                    }

                    // > Button
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Image {
                            anchors.centerIn: parent
                            width: 12
                            height: 12
                            source: "file://" + AppConfig.assetsDir + "/chevron-right.svg"
                            opacity: nextMouse.containsMouse ? 1.0 : 0.7
                        }

                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.goToNextPage()
                        }
                    }
                }
            }

            // Title & Indicator Dots
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 3

                Text {
                    text: root.pageTitles[swipeView.currentIndex] || "Control Hub"
                    color: "#f8fafc"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                // Interactive Page Dots
                Row {
                    spacing: 4
                    Repeater {
                        model: swipeView.count
                        Rectangle {
                            required property int index
                            width: swipeView.currentIndex === index ? 14 : 5
                            height: 5
                            radius: 2.5
                            color: swipeView.currentIndex === index ? "#38bdf8" : "#475569"

                            Behavior on width {
                                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: swipeView.currentIndex = index
                            }
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Close button (✕)
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: closeMouse.containsMouse ? "#3b3b4a" : "#1e1e28"
                border.color: "#2d2d3c"
                border.width: 1

                Image {
                    anchors.centerIn: parent
                    width: 12
                    height: 12
                    source: "file://" + AppConfig.assetsDir + "/close.svg"
                }

                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.collapse()
                }
            }
        }

        // =====================================================================
        // BODY: SWIPEVIEW WITH 4 RICH PAGES
        // =====================================================================
        SwipeView {
            id: swipeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: 0
            clip: true

            // Allow keyboard Left/Right arrow navigation
            focus: true
            Keys.onLeftPressed: root.goToPrevPage()
            Keys.onRightPressed: root.goToNextPage()

            // -----------------------------------------------------------------
            // PAGE 0: SISTEM & MONITORING
            // -----------------------------------------------------------------
            Item {
                id: pageSystem
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    // Resource Meters (CPU, RAM, Battery)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // CPU Box
                        Rectangle {
                            Layout.fillWidth: true
                            height: 60
                            radius: 10
                            color: "#121217"
                            border.color: "#22222a"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    Image {
                                        width: 14
                                        height: 14
                                        source: "file://" + AppConfig.assetsDir + "/cpu.svg"
                                    }
                                    Text {
                                        text: "CPU"
                                        color: "#94a3b8"
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: IslandController.cpuPercent + "%"
                                        color: "#f8fafc"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 4
                                    radius: 2
                                    color: "#27272a"
                                    Rectangle {
                                        width: parent.width * (IslandController.cpuPercent / 100.0)
                                        height: parent.height
                                        radius: parent.radius
                                        color: IslandController.cpuPercent > 80 ? "#ef4444" : "#38bdf8"
                                    }
                                }
                            }
                        }

                        // RAM Box
                        Rectangle {
                            Layout.fillWidth: true
                            height: 60
                            radius: 10
                            color: "#121217"
                            border.color: "#22222a"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    Image {
                                        width: 14
                                        height: 14
                                        source: "file://" + AppConfig.assetsDir + "/memory.svg"
                                    }
                                    Text {
                                        text: "RAM"
                                        color: "#94a3b8"
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: IslandController.ramPercent + "%"
                                        color: "#f8fafc"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 4
                                    radius: 2
                                    color: "#27272a"
                                    Rectangle {
                                        width: parent.width * (IslandController.ramPercent / 100.0)
                                        height: parent.height
                                        radius: parent.radius
                                        color: IslandController.ramPercent > 85 ? "#ef4444" : "#818cf8"
                                    }
                                }
                            }
                        }

                        // Battery Box
                        Rectangle {
                            Layout.fillWidth: true
                            height: 60
                            radius: 10
                            color: "#121217"
                            border.color: "#22222a"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    Image {
                                        width: 14
                                        height: 14
                                        source: IslandController.isCharging 
                                                ? "file://" + AppConfig.assetsDir + "/bolt.svg"
                                                : "file://" + AppConfig.assetsDir + "/battery.svg"
                                    }
                                    Text {
                                        text: IslandController.isCharging ? "Charging" : "Baterai"
                                        color: "#94a3b8"
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: IslandController.batteryPercent + "%"
                                        color: IslandController.isCharging ? "#22c55e" : "#f8fafc"
                                        font.pixelSize: 11
                                        font.weight: Font.Bold
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 4
                                    radius: 2
                                    color: "#27272a"
                                    Rectangle {
                                        width: parent.width * (IslandController.batteryPercent / 100.0)
                                        height: parent.height
                                        radius: parent.radius
                                        color: IslandController.isCharging ? "#22c55e" : "#38bdf8"
                                    }
                                }
                            }
                        }
                    }

                    // Bottom: Timer & Quick Mute & Test
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // Timer Card
                        Rectangle {
                            Layout.fillWidth: true
                            height: 52
                            radius: 10
                            color: "#121217"
                            border.color: "#22222a"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 8

                                Image {
                                    width: 14
                                    height: 14
                                    source: "file://" + AppConfig.assetsDir + "/timer.svg"
                                }

                                Text {
                                    text: IslandController.timerRemaining > 0 ? IslandController.timerFormatted : "Timer"
                                    color: IslandController.timerRunning ? "#f59e0b" : "#f8fafc"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                }

                                Item { Layout.fillWidth: true }

                                // Preset buttons
                                Row {
                                    spacing: 4
                                    visible: IslandController.timerRemaining === 0

                                    Repeater {
                                        model: [
                                            { label: "1m", sec: 60 },
                                            { label: "5m", sec: 300 },
                                            { label: "25m", sec: 1500 }
                                        ]
                                        Rectangle {
                                            required property var modelData
                                            width: 28
                                            height: 22
                                            radius: 4
                                            color: tBtnMouse.containsMouse ? "#27272a" : "#1a1a22"

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.label
                                                color: "#cbd5e1"
                                                font.pixelSize: 9
                                            }

                                            MouseArea {
                                                id: tBtnMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: IslandController.startTimer(modelData.sec)
                                            }
                                        }
                                    }
                                }

                                // Running Controls
                                Row {
                                    spacing: 4
                                    visible: IslandController.timerRemaining > 0

                                    Rectangle {
                                        width: 44
                                        height: 22
                                        radius: 4
                                        color: pMouse.containsMouse ? "#27272a" : "#1a1a22"
                                        Text {
                                            anchors.centerIn: parent
                                            text: IslandController.timerRunning ? "Pause" : "Start"
                                            color: "#38bdf8"
                                            font.pixelSize: 9
                                        }
                                        MouseArea {
                                            id: pMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: IslandController.toggleTimer()
                                        }
                                    }

                                    Rectangle {
                                        width: 36
                                        height: 22
                                        radius: 4
                                        color: rMouse.containsMouse ? "#27272a" : "#1a1a22"
                                        Text {
                                            anchors.centerIn: parent
                                            text: "Reset"
                                            color: "#ef4444"
                                            font.pixelSize: 9
                                        }
                                        MouseArea {
                                            id: rMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: IslandController.resetTimer()
                                        }
                                    }
                                }
                            }
                        }

                        // Mute button
                        Rectangle {
                            width: 52
                            height: 52
                            radius: 10
                            color: muteMouse.containsMouse ? "#27272a" : "#121217"
                            border.color: IslandController.isMuted ? "#ef4444" : "#22222a"
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 2
                                Image {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 14
                                    height: 14
                                    source: IslandController.isMuted
                                            ? "file://" + AppConfig.assetsDir + "/volume-mute.svg"
                                            : "file://" + AppConfig.assetsDir + "/volume-high.svg"
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: IslandController.isMuted ? "Unmute" : "Mute"
                                    color: IslandController.isMuted ? "#ef4444" : "#94a3b8"
                                    font.pixelSize: 8
                                }
                            }

                            MouseArea {
                                id: muteMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: IslandController.toggleMute()
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // PAGE 1: PEMUTAR MUSIK
            // -----------------------------------------------------------------
            Item {
                id: pageMusic

                // When media exists
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8
                    visible: IslandController.mediaHasTrack

                    // Track info row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            width: 44
                            height: 44
                            radius: 10
                            color: "#18181f"
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: IslandController.mediaArtUrl
                                fillMode: Image.PreserveAspectCrop
                                visible: IslandController.mediaArtUrl !== ""
                            }
                            Image {
                                anchors.centerIn: parent
                                width: 20
                                height: 20
                                source: "file://" + AppConfig.assetsDir + "/music.svg"
                                visible: IslandController.mediaArtUrl === ""
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                Layout.fillWidth: true
                                text: IslandController.mediaTitle
                                color: "#ffffff"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                            Text {
                                Layout.fillWidth: true
                                text: IslandController.mediaArtist
                                color: "#94a3b8"
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }
                    }

                    // Seek timeline
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Rectangle {
                            id: hubProgressBar
                            Layout.fillWidth: true
                            height: 5
                            radius: 2.5
                            color: "#27272a"

                            Rectangle {
                                width: hubProgressBar.width * IslandController.mediaPositionRatio
                                height: parent.height
                                radius: parent.radius
                                color: "#38bdf8"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: (mouse) => {
                                    var ratio = Math.max(0.0, Math.min(1.0, mouse.x / width))
                                    IslandController.mediaSeek(ratio)
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: IslandController.mediaPositionFormatted
                                color: "#64748b"
                                font.pixelSize: 9
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: IslandController.mediaDurationFormatted
                                color: "#64748b"
                                font.pixelSize: 9
                            }
                        }
                    }

                    // Media playback buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: mPrevMouse.containsMouse ? "#2f313f" : "#1a1b24"
                            border.color: "#282937"
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                width: 14
                                height: 14
                                source: "file://" + AppConfig.assetsDir + "/prev.svg"
                            }
                            MouseArea {
                                id: mPrevMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: IslandController.mediaPrevious()
                            }
                        }

                        Rectangle {
                            width: 38
                            height: 38
                            radius: 19
                            color: mPlayMouse.containsMouse ? "#0284c7" : "#0ea5e9"

                            Image {
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                source: IslandController.mediaIsPlaying
                                        ? "file://" + AppConfig.assetsDir + "/pause.svg"
                                        : "file://" + AppConfig.assetsDir + "/play.svg"
                            }
                            MouseArea {
                                id: mPlayMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: IslandController.mediaPlayPause()
                            }
                        }

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: mNextMouse.containsMouse ? "#2f313f" : "#1a1b24"
                            border.color: "#282937"
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                width: 14
                                height: 14
                                source: "file://" + AppConfig.assetsDir + "/next.svg"
                            }
                            MouseArea {
                                id: mNextMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: IslandController.mediaNext()
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Volume mini slider
                        RowLayout {
                            spacing: 6
                            Image {
                                width: 14
                                height: 14
                                source: IslandController.isMuted
                                        ? "file://" + AppConfig.assetsDir + "/volume-mute.svg"
                                        : "file://" + AppConfig.assetsDir + "/volume-high.svg"
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: IslandController.toggleMute()
                                }
                            }
                            Rectangle {
                                id: hubVolBar
                                width: 65
                                height: 5
                                radius: 2.5
                                color: "#27272a"
                                Rectangle {
                                    width: hubVolBar.width * IslandController.volume
                                    height: parent.height
                                    radius: parent.radius
                                    color: IslandController.isMuted ? "#ef4444" : "#38bdf8"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: (mouse) => {
                                        var r = Math.max(0.0, Math.min(1.0, mouse.x / width))
                                        IslandController.setVolume(r)
                                    }
                                }
                            }
                        }
                    }
                }

                // Placeholder when no media is playing
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: !IslandController.mediaHasTrack

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 44
                        height: 44
                        radius: 22
                        color: "#181822"
                        border.color: "#282838"
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            width: 20
                            height: 20
                            source: "file://" + AppConfig.assetsDir + "/music.svg"
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Tidak Ada Media Aktif"
                        color: "#f8fafc"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Putar lagu di Spotify atau video di browser untuk kendali cepat"
                        color: "#64748b"
                        font.pixelSize: 10
                    }
                }
            }

            // -----------------------------------------------------------------
            // PAGE 2: PINTASAN CEPAT (QUICK TOOLS)
            // -----------------------------------------------------------------
            Item {
                id: pageTools

                GridLayout {
                    anchors.fill: parent
                    columns: 3
                    rowSpacing: 8
                    columnSpacing: 8

                    // 1. Screenshot Tool
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: ssMouse.containsMouse ? "#20202c" : "#121217"
                        border.color: "#22222a"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Image {
                                width: 18
                                height: 18
                                source: "file://" + AppConfig.assetsDir + "/camera.svg"
                            }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Screenshot"; color: "#f8fafc"; font.pixelSize: 11; font.weight: Font.DemiBold }
                                Text { text: "Area Layar"; color: "#64748b"; font.pixelSize: 9 }
                            }
                        }

                        MouseArea {
                            id: ssMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                IslandController.collapse()
                                IslandController.takeScreenshot()
                            }
                        }
                    }

                    // 2. Night Light Toggle
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: nlMouse.containsMouse ? "#20202c" : "#121217"
                        border.color: IslandController.nightLightActive ? "#818cf8" : "#22222a"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Image {
                                width: 18
                                height: 18
                                source: "file://" + AppConfig.assetsDir + "/moon.svg"
                            }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Night Light"; color: "#f8fafc"; font.pixelSize: 11; font.weight: Font.DemiBold }
                                Text { 
                                    text: IslandController.nightLightActive ? "Aktif" : "Mati"
                                    color: IslandController.nightLightActive ? "#818cf8" : "#64748b"
                                    font.pixelSize: 9 
                                }
                            }
                        }

                        MouseArea {
                            id: nlMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.toggleNightLight()
                        }
                    }

                    // 3. Lock Screen
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: lockMouse.containsMouse ? "#20202c" : "#121217"
                        border.color: "#22222a"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Image {
                                width: 18
                                height: 18
                                source: "file://" + AppConfig.assetsDir + "/lock.svg"
                            }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Kunci Layar"; color: "#f8fafc"; font.pixelSize: 11; font.weight: Font.DemiBold }
                                Text { text: "Lock Session"; color: "#64748b"; font.pixelSize: 9 }
                            }
                        }

                        MouseArea {
                            id: lockMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.lockScreen()
                        }
                    }

                    // 4. Konsole Terminal
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: termMouse.containsMouse ? "#20202c" : "#121217"
                        border.color: "#22222a"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Image {
                                width: 18
                                height: 18
                                source: "file://" + AppConfig.assetsDir + "/terminal.svg"
                            }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Konsole"; color: "#f8fafc"; font.pixelSize: 11; font.weight: Font.DemiBold }
                                Text { text: "Terminal KDE"; color: "#64748b"; font.pixelSize: 9 }
                            }
                        }

                        MouseArea {
                            id: termMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                IslandController.collapse()
                                IslandController.openTerminal()
                            }
                        }
                    }

                    // 5. System Settings
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: setMouse.containsMouse ? "#20202c" : "#121217"
                        border.color: "#22222a"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Image {
                                width: 18
                                height: 18
                                source: "file://" + AppConfig.assetsDir + "/settings.svg"
                            }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Pengaturan"; color: "#f8fafc"; font.pixelSize: 11; font.weight: Font.DemiBold }
                                Text { text: "KDE Settings"; color: "#64748b"; font.pixelSize: 9 }
                            }
                        }

                        MouseArea {
                            id: setMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                IslandController.collapse()
                                IslandController.openSettings()
                            }
                        }
                    }

                    // 6. Test Notification
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: notifMouse.containsMouse ? "#20202c" : "#121217"
                        border.color: "#22222a"
                        border.width: 1

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            Image {
                                width: 18
                                height: 18
                                source: "file://" + AppConfig.assetsDir + "/bell.svg"
                            }
                            ColumnLayout {
                                spacing: 0
                                Text { text: "Notifikasi"; color: "#f8fafc"; font.pixelSize: 11; font.weight: Font.DemiBold }
                                Text { text: "Tes Pop-up"; color: "#64748b"; font.pixelSize: 9 }
                            }
                        }

                        MouseArea {
                            id: notifMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                IslandController.collapse()
                                IslandController.triggerTestNotification()
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // PAGE 3: JARINGAN & INFORMASI SISTEM
            // -----------------------------------------------------------------
            Item {
                id: pageNet
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    // Network Speed Monitor Cards
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // Download Speed
                        Rectangle {
                            Layout.fillWidth: true
                            height: 56
                            radius: 10
                            color: "#121217"
                            border.color: "#22222a"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Image {
                                    width: 18
                                    height: 18
                                    source: "file://" + AppConfig.assetsDir + "/network.svg"
                                }

                                ColumnLayout {
                                    spacing: 0
                                    Text {
                                        text: "Unduh (Down)"
                                        color: "#94a3b8"
                                        font.pixelSize: 9
                                    }
                                    Text {
                                        text: IslandController.netDownSpeed
                                        color: "#38bdf8"
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                    }
                                }
                            }
                        }

                        // Upload Speed
                        Rectangle {
                            Layout.fillWidth: true
                            height: 56
                            radius: 10
                            color: "#121217"
                            border.color: "#22222a"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 8

                                Image {
                                    width: 18
                                    height: 18
                                    source: "file://" + AppConfig.assetsDir + "/network.svg"
                                }

                                ColumnLayout {
                                    spacing: 0
                                    Text {
                                        text: "Unggah (Up)"
                                        color: "#94a3b8"
                                        font.pixelSize: 9
                                    }
                                    Text {
                                        text: IslandController.netUpSpeed
                                        color: "#22c55e"
                                        font.pixelSize: 13
                                        font.weight: Font.Bold
                                    }
                                }
                            }
                        }
                    }

                    // System Info Box
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: "#121217"
                        border.color: "#22222a"
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Distro & Desktop:"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: IslandController.osInfo
                                    color: "#f8fafc"
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Kernel Linux:"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: IslandController.kernelInfo
                                    color: "#38bdf8"
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: "Sesi Wayland:"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: "Layer-Shell Active (60/144 FPS)"
                                    color: "#22c55e"
                                    font.pixelSize: 10
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // PAGE 4: KESEHATAN & PELACAK AIR
            // -----------------------------------------------------------------
            PageHealth {
                id: pageHealth
            }

            // -----------------------------------------------------------------
            // PAGE 5: DAFTAR TUGAS (TO-DO)
            // -----------------------------------------------------------------
            PageTodo {
                id: pageTodo
            }
        }
    }
}
