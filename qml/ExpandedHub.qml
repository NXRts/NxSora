import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    implicitWidth: 420
    implicitHeight: 245

    // 10 Main Swipeable Module Pages (Settings is separated into its own view)
    readonly property var pageTitles: [
        "Sistem & Pomodoro Fokus",
        IslandController.lyricsModeActive ? "Musik & Lirik Karaoke" : "Pemutar Musik",
        "Pintasan Cepat",
        "Cuaca & Hari Ini",
        "Hardware, Suhu & TDP",
        "Bluetooth & Perangkat",
        "Pusat Notifikasi",
        "Kesehatan & Air",
        "Daftar Tugas (To-Do)",
        "Rak File (Shelf)"
    ]

    readonly property bool isSettingsOpen: IslandController.isSettingsViewOpen

    function jumpToPageInstant(idx) {
        if (!pageContainer) return;
        pageContainer.goTo(idx, 0);
    }

    Connections {
        target: IslandController
        function onActiveHubPageChanged() {
            if (pageContainer.currentIndex !== IslandController.activeHubPage) {
                root.jumpToPageInstant(IslandController.activeHubPage);
            }
        }
        function onIsExpandedChanged() {
            if (IslandController.isExpanded) {
                root.jumpToPageInstant(IslandController.activeHubPage);
            }
        }
    }

    Component.onCompleted: {
        root.jumpToPageInstant(IslandController.activeHubPage);
    }

    function goToPrevPage() {
        if (!pageContainer) return;
        var nextIdx = (pageContainer.currentIndex > 0) ? pageContainer.currentIndex - 1 : pageContainer.count - 1;
        pageContainer.goTo(nextIdx, -1);
    }

    function goToNextPage() {
        if (!pageContainer) return;
        var nextIdx = (pageContainer.currentIndex < pageContainer.count - 1) ? pageContainer.currentIndex + 1 : 0;
        pageContainer.goTo(nextIdx, 1);
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // =====================================================================
        // HEADER: [ < | > ] [Title + Page Indicator Dots] [Pin + Close Button]
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Top Left Action Capsule (Smoothly adapts between 62px [ < | > ] and 76px [ ‹ Kembali ])
            Rectangle {
                id: navCapsule
                Layout.preferredWidth: root.isSettingsOpen ? 76 : 62
                Layout.preferredHeight: 28
                radius: 14
                color: (root.isSettingsOpen && backMouse.containsMouse)
                       ? "#282a3d"
                       : "#181a26"
                border.color: (root.isSettingsOpen && backMouse.containsMouse)
                              ? "#38bdf8"
                              : "#282b3d"
                border.width: 1

                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                }

                // 1. Navigation Arrows (< >) when Settings is closed
                RowLayout {
                    anchors.fill: parent
                    spacing: 0
                    visible: !root.isSettingsOpen

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

                // 2. [ ‹ Kembali ] Button when Settings is open (Well-padded, zero cramped text!)
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    visible: root.isSettingsOpen

                    Image {
                        width: 10
                        height: 10
                        sourceSize: Qt.size(10, 10)
                        source: "file://" + AppConfig.assetsDir + "/chevron-left.svg"
                        opacity: backMouse.containsMouse ? 1.0 : 0.8
                    }

                    Text {
                        text: "Kembali"
                        color: backMouse.containsMouse ? "#38bdf8" : "#f8fafc"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }

                MouseArea {
                    id: backMouse
                    anchors.fill: parent
                    enabled: root.isSettingsOpen
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.closeSettingsView()
                }
            }

            // Title & Indicator Dots / Subtitle (Rock solid baseline, perfectly aligned)
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    text: root.isSettingsOpen ? "Pengaturan" : (root.pageTitles[pageContainer.currentIndex] || "Control Hub")
                    color: "#f8fafc"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                // Interactive Page Dots (9 main pages)
                Row {
                    visible: !root.isSettingsOpen
                    spacing: 4
                    Repeater {
                        model: pageContainer.count
                        Rectangle {
                            required property int index
                            width: pageContainer.currentIndex === index ? 14 : 5
                            height: 5
                            radius: 2.5
                            color: pageContainer.currentIndex === index ? "#38bdf8" : "#475569"

                            Behavior on width {
                                NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (index !== pageContainer.currentIndex) {
                                        var dir = (index > pageContainer.currentIndex) ? 1 : -1;
                                        pageContainer.goTo(index, dir);
                                    }
                                }
                            }
                        }
                    }
                }

                // Clean, elegant subtitle when in Settings (No jarring bullet dots or neon text!)
                Text {
                    visible: root.isSettingsOpen
                    text: "Preferensi Island"
                    color: "#64748b"
                    font.pixelSize: 9
                    font.weight: Font.Normal
                }
            }

            // KDE Virtual Desktop Switcher in Header (when > 1 workspace)
            Row {
                visible: !root.isSettingsOpen && IslandController.workspaceCount > 1
                spacing: 4
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                    model: IslandController.workspacesList
                    Rectangle {
                        required property var modelData
                        width: 18
                        height: 18
                        radius: 9
                        color: modelData.isCurrent ? "#0284c7" : (wsHdrMouse.containsMouse ? "#272a3e" : "#181a26")
                        border.color: modelData.isCurrent ? "#38bdf8" : "#282a3d"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: String(modelData.index + 1)
                            color: modelData.isCurrent ? "#ffffff" : "#94a3b8"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: wsHdrMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.switchToWorkspace(modelData.index)
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Action Buttons: [Notifikasi 🔔], [Pin 📌] and [Close ✕]
            RowLayout {
                spacing: 6

                // Notification Center Shortcut Button (🔔 with Unread Badge)
                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: pageContainer.currentIndex === 5
                           ? "#251e4a"
                           : (bellHdrMouse.containsMouse ? "#2d2d3a" : "#181a24")
                    border.color: pageContainer.currentIndex === 5 || IslandController.notifUnreadCount > 0
                                  ? "#818cf8"
                                  : (bellHdrMouse.containsMouse ? "#3b3b4a" : "#282a36")
                    border.width: pageContainer.currentIndex === 5 || IslandController.notifUnreadCount > 0 ? 1.5 : 1

                    Image {
                        anchors.centerIn: parent
                        width: 12
                        height: 12
                        sourceSize: Qt.size(12, 12)
                        source: "file://" + AppConfig.assetsDir + "/bell.svg"
                        opacity: pageContainer.currentIndex === 5 || IslandController.notifUnreadCount > 0 ? 1.0 : 0.7
                    }

                    // Unread Dot / Count Badge
                    Rectangle {
                        visible: IslandController.notifUnreadCount > 0
                        width: 13
                        height: 13
                        radius: 6.5
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.rightMargin: -2
                        anchors.topMargin: -2
                        color: "#6366f1"
                        border.color: "#09090d"
                        border.width: 1.5

                        Text {
                            anchors.centerIn: parent
                            text: IslandController.notifUnreadCount > 9 ? "9+" : String(IslandController.notifUnreadCount)
                            color: "#ffffff"
                            font.pixelSize: 7
                            font.weight: Font.Black
                        }
                    }

                    MouseArea {
                        id: bellHdrMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (pageContainer.currentIndex !== 6) {
                                var dir = (6 > pageContainer.currentIndex) ? 1 : -1;
                                pageContainer.goTo(6, dir);
                            }
                        }
                    }
                }

                // Pin Button (📌 toggle auto-collapse)
                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: IslandController.isPinned ? "#1e293b" : (pinMouse.containsMouse ? "#2d2d3a" : "#181a24")
                    border.color: IslandController.isPinned ? "#38bdf8" : (pinMouse.containsMouse ? "#3b3b4a" : "#282a36")
                    border.width: IslandController.isPinned ? 1.5 : 1

                    Image {
                        anchors.centerIn: parent
                        width: 12
                        height: 12
                        source: "file://" + AppConfig.assetsDir + "/pin.svg"
                        opacity: IslandController.isPinned ? 1.0 : (pinMouse.containsMouse ? 0.9 : 0.6)
                    }

                    MouseArea {
                        id: pinMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.togglePin()
                    }
                }

                // Settings Button (⚙️ toggle separate Settings View)
                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: root.isSettingsOpen ? "#1e293b" : (settingsHdrMouse.containsMouse ? "#2d2d3a" : "#181a24")
                    border.color: root.isSettingsOpen ? "#38bdf8" : (settingsHdrMouse.containsMouse ? "#3b3b4a" : "#282a36")
                    border.width: root.isSettingsOpen ? 1.5 : 1

                    Image {
                        anchors.centerIn: parent
                        width: 12
                        height: 12
                        source: "file://" + AppConfig.assetsDir + "/settings.svg"
                        opacity: root.isSettingsOpen ? 1.0 : (settingsHdrMouse.containsMouse ? 0.9 : 0.6)
                    }

                    MouseArea {
                        id: settingsHdrMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: IslandController.toggleSettingsView()
                    }
                }

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
        }

        // =====================================================================
        // BODY: DIRECTIONAL CAROUSEL CONTAINER (9 MAIN PAGES) + SWIPE GESTURE
        // =====================================================================
        Item {
            id: pageContainer
            visible: !root.isSettingsOpen
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            property int currentIndex: IslandController.activeHubPage
            readonly property int count: 10
            readonly property var pages: [pageSystem, pageMusic, pageTools, pageWeather, pageNet, pageBluetooth, pageNotifications, pageHealth, pageTodo, pageShelf]
            readonly property bool isChildSliderActive: seekMouseArea.pressed || seekMouseArea.isDragging || hubVolBarMouse.pressed || lyricsVolMouse.pressed || brightnessSliderMouse.pressed || pageShelf.isCardPressed

            // Allow keyboard Left/Right arrow navigation & Esc to close
            focus: !root.isSettingsOpen
            Keys.onLeftPressed: root.goToPrevPage()
            Keys.onRightPressed: root.goToNextPage()
            Keys.onEscapePressed: {
                if (root.isSettingsOpen) {
                    IslandController.closeSettingsView();
                } else {
                    IslandController.collapse();
                }
            }

            // Cooldown timer for touchpad / mouse wheel horizontal page swiping
            Timer {
                id: wheelSwipeCooldown
                interval: 230
                repeat: false
            }

            // Touchpad Horizontal 2-Finger Swipe ONLY (Mouse vertical scroll wheel disabled for page switching)
            WheelHandler {
                id: horizontalWheelSwipe
                orientation: Qt.Horizontal
                acceptedDevices: PointerDevice.TouchPad
                onWheel: (event) => {
                    if (wheelSwipeCooldown.running || slideAnim.running) {
                        event.accepted = true;
                        return;
                    }
                    var delta = event.angleDelta.x !== 0 ? event.angleDelta.x : event.pixelDelta.x;
                    if (Math.abs(delta) >= 18) {
                        wheelSwipeCooldown.restart();
                        if (delta < 0) {
                            root.goToNextPage();
                        } else {
                            root.goToPrevPage();
                        }
                        event.accepted = true;
                    }
                }
            }

            // Interactive Mouse / Touchpad Drag-to-Swipe Handler (like SwipeView + continuous wrap)
            DragHandler {
                id: swipeDragHandler
                target: null
                enabled: !pageContainer.isChildSliderActive
                xAxis.enabled: true
                yAxis.enabled: false
                dragThreshold: 12

                property real lastDx: 0

                onActiveTranslationChanged: {
                    if (active) {
                        lastDx = activeTranslation.x;
                        pageContainer.updateInteractiveSwipe(lastDx);
                    }
                }

                onActiveChanged: {
                    if (!active) {
                        pageContainer.finishInteractiveSwipe(lastDx);
                        lastDx = 0;
                    }
                }
            }

            ParallelAnimation {
                id: slideAnim
                property Item oldPage: null
                property Item newPage: null
                property real oldTargetX: 0
                property real newTargetX: 0

                NumberAnimation {
                    target: slideAnim.oldPage
                    property: "x"
                    to: slideAnim.oldTargetX
                    duration: 210
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: slideAnim.newPage
                    property: "x"
                    to: slideAnim.newTargetX
                    duration: 210
                    easing.type: Easing.OutCubic
                }
                onFinished: {
                    for (var i = 0; i < pageContainer.count; i++) {
                        if (pageContainer.pages[i]) {
                            pageContainer.pages[i].visible = (i === pageContainer.currentIndex);
                            if (i === pageContainer.currentIndex) {
                                pageContainer.pages[i].x = 0;
                            }
                        }
                    }
                }
            }

            function updateInteractiveSwipe(dx) {
                slideAnim.stop();
                var w = pageContainer.width > 0 ? pageContainer.width : 392;
                var curIdx = currentIndex;
                var nextIdx = (curIdx + 1) % count;
                var prevIdx = (curIdx - 1 + count) % count;
                var neighborIdx = (dx < 0) ? nextIdx : prevIdx;

                for (var i = 0; i < count; i++) {
                    if (!pages[i]) continue;
                    if (i === curIdx) {
                        pages[i].visible = true;
                        pages[i].x = dx;
                    } else if (i === neighborIdx && Math.abs(dx) > 1) {
                        pages[i].visible = true;
                        pages[i].x = (dx < 0) ? (w + dx) : (-w + dx);
                    } else {
                        pages[i].visible = false;
                        pages[i].x = w;
                    }
                }
            }

            function finishInteractiveSwipe(dx) {
                var w = pageContainer.width > 0 ? pageContainer.width : 392;
                var curIdx = currentIndex;
                var curP = pages[curIdx];
                if (!curP) return;

                if (Math.abs(dx) < 2) {
                    goTo(curIdx, 0);
                    return;
                }

                var dir = (dx < 0) ? 1 : -1;
                var neighborIdx = (dir > 0) ? ((curIdx + 1) % count) : ((curIdx - 1 + count) % count);
                var neighborP = pages[neighborIdx];

                if (Math.abs(dx) >= 48 && neighborP) {
                    // Commit swipe to neighbor page from current dragged position
                    slideAnim.stop();
                    slideAnim.oldPage = curP;
                    slideAnim.newPage = neighborP;
                    slideAnim.oldTargetX = (dir > 0) ? -w : w;
                    slideAnim.newTargetX = 0;

                    currentIndex = neighborIdx;
                    IslandController.setActiveHubPage(neighborIdx);
                    slideAnim.restart();
                } else if (neighborP) {
                    // Snap back to current page
                    slideAnim.stop();
                    slideAnim.oldPage = neighborP;
                    slideAnim.newPage = curP;
                    slideAnim.oldTargetX = (dir > 0) ? w : -w;
                    slideAnim.newTargetX = 0;
                    slideAnim.restart();
                } else {
                    goTo(curIdx, 0);
                }
            }

            function goTo(newIdx, dir) {
                if (newIdx < 0 || newIdx >= count) return;
                var oldIdx = currentIndex;

                slideAnim.stop();

                var oldP = pages[oldIdx];
                var newP = pages[newIdx];

                if (dir === 0 || !oldP || !newP || oldIdx === newIdx) {
                    for (var i = 0; i < count; i++) {
                        if (pages[i]) {
                            pages[i].visible = (i === newIdx);
                            pages[i].x = 0;
                        }
                    }
                    currentIndex = newIdx;
                    IslandController.setActiveHubPage(newIdx);
                    return;
                }

                var w = pageContainer.width > 0 ? pageContainer.width : 392;

                for (var j = 0; j < count; j++) {
                    if (pages[j] && j !== oldIdx && j !== newIdx) {
                        pages[j].visible = false;
                        pages[j].x = w;
                    }
                }

                oldP.visible = true;
                oldP.x = 0;

                newP.visible = true;
                newP.x = (dir > 0) ? w : -w;

                slideAnim.oldPage = oldP;
                slideAnim.newPage = newP;
                slideAnim.oldTargetX = (dir > 0) ? -w : w;
                slideAnim.newTargetX = 0;

                currentIndex = newIdx;
                IslandController.setActiveHubPage(newIdx);
                slideAnim.restart();
            }

            Component.onCompleted: {
                goTo(IslandController.activeHubPage, 0);
            }

            // -----------------------------------------------------------------
            // PAGE 0: SISTEM & POMODORO FOCUS TIMER
            // -----------------------------------------------------------------
            Item {
                id: pageSystem
                width: pageContainer.width
                height: pageContainer.height
                y: 0
                ColumnLayout {
                    anchors.fill: parent
                    spacing: 8

                    // 1. Compact Resource Meters (CPU, RAM, Battery)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // CPU + Temp + TDP Box (Click to jump to Page 3 Hardware & TDP)
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            height: 48
                            radius: 10
                            color: cpuBoxMouse.containsMouse ? "#181924" : "#121217"
                            border.color: IslandController.cpuTemp >= 80 ? "#ef4444" : (cpuBoxMouse.containsMouse ? "#38bdf8" : "#22222a")
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 7
                                spacing: 3

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    Image {
                                        Layout.preferredWidth: 12
                                        Layout.preferredHeight: 12
                                        sourceSize.width: 12
                                        sourceSize.height: 12
                                        source: "file://" + AppConfig.assetsDir + "/cpu.svg"
                                    }
                                    Text {
                                        text: IslandController.cpuTemp + "°C"
                                        color: IslandController.cpuTemp >= 80 ? "#ef4444" : (IslandController.cpuTemp >= 62 ? "#f59e0b" : "#22c55e")
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                    }
                                    Text {
                                        text: "· " + IslandController.cpuTdpText
                                        color: "#38bdf8"
                                        font.pixelSize: 9
                                        font.weight: Font.DemiBold
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: IslandController.cpuPercent + "%"
                                        color: "#f8fafc"
                                        font.pixelSize: 10
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

                            MouseArea {
                                id: cpuBoxMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: pageContainer.goTo(4, 1)
                            }
                        }

                        // RAM Box
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            height: 48
                            radius: 10
                            color: "#121217"
                            border.color: "#22222a"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 7
                                spacing: 3

                                RowLayout {
                                    Layout.fillWidth: true
                                    Image {
                                        Layout.preferredWidth: 12
                                        Layout.preferredHeight: 12
                                        sourceSize.width: 12
                                        sourceSize.height: 12
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
                            Layout.preferredWidth: 1
                            height: 48
                            radius: 10
                            color: "#121217"
                            border.color: "#22222a"
                            border.width: 1

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 7
                                spacing: 3

                                RowLayout {
                                    Layout.fillWidth: true
                                    Image {
                                        Layout.preferredWidth: 12
                                        Layout.preferredHeight: 12
                                        sourceSize.width: 12
                                        sourceSize.height: 12
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

                    // 2. Bottom Row: POMODORO FOCUS TIMER RING + QUICK MUTE
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        // POMODORO FOCUS TIMER CARD
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 12
                            color: "#11131d"
                            border.color: IslandController.timerRunning
                                          ? (IslandController.timerMode === "focus" ? "#f43f5e" : "#38bdf8")
                                          : "#222436"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 14
                                anchors.rightMargin: 12
                                spacing: 14

                                // --- LEFT: GLOWING CONIC RING (Conic Ring & Glow) ---
                                Item {
                                    width: 68
                                    height: 68
                                    Layout.alignment: Qt.AlignVCenter

                                    // Soft radial glow behind the ring
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 66
                                        height: 66
                                        radius: 33
                                        color: IslandController.timerMode === "focus" ? "#ff4b55" : "#38bdf8"
                                        opacity: IslandController.timerRunning ? 0.24 : 0.12
                                        Behavior on opacity { NumberAnimation { duration: 300 } }
                                    }

                                    // Circular Progress Ring Canvas
                                    Canvas {
                                        id: pomoRingCanvas
                                        anchors.fill: parent
                                        property real progress: IslandController.timerProgressRatio
                                        property string mode: IslandController.timerMode

                                        onProgressChanged: requestPaint()
                                        onModeChanged: requestPaint()
                                        Component.onCompleted: requestPaint()

                                        onPaint: {
                                            var ctx = getContext("2d");
                                            ctx.reset();
                                            var cx = width / 2;
                                            var cy = height / 2;
                                            var r = 27;
                                            var startAngle = -Math.PI / 2;
                                            var endAngle = startAngle + (Math.PI * 2 * Math.max(0.02, progress));

                                            // Track circle
                                            ctx.beginPath();
                                            ctx.arc(cx, cy, r, 0, Math.PI * 2);
                                            ctx.lineWidth = 6.5;
                                            ctx.strokeStyle = mode === "focus" ? "rgba(255, 90, 110, 0.20)" : "rgba(56, 189, 248, 0.20)";
                                            ctx.stroke();

                                            // Active arc
                                            ctx.beginPath();
                                            ctx.arc(cx, cy, r, startAngle, endAngle);
                                            ctx.lineWidth = 6.5;
                                            ctx.lineCap = "round";
                                            var grad = ctx.createLinearGradient(0, 0, width, height);
                                            if (mode === "focus") {
                                                grad.addColorStop(0.0, "#ff6b5f");
                                                grad.addColorStop(0.5, "#ff3a3a");
                                                grad.addColorStop(1.0, "#ff5a6e");
                                            } else {
                                                grad.addColorStop(0.0, "#66dbff");
                                                grad.addColorStop(1.0, "#2563eb");
                                            }
                                            ctx.strokeStyle = grad;
                                            ctx.stroke();
                                        }
                                    }

                                    // Center Stopwatch Icon
                                    Image {
                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        source: "file://" + AppConfig.assetsDir + "/timer.svg"
                                    }
                                }

                                // --- RIGHT: TIME READOUT, RESET & 3 PILL BUTTONS ---
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 6

                                    // Top Row: Big Time + Mode Label + Reset Circle
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Text {
                                            text: IslandController.timerFormatted
                                            color: "#ffffff"
                                            font.pixelSize: 24
                                            font.weight: Font.ExtraBold
                                            font.letterSpacing: -0.5
                                        }

                                        ColumnLayout {
                                            spacing: 0
                                            Text {
                                                text: "Pomodoro"
                                                color: "#f8fafc"
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                            }
                                            Text {
                                                text: IslandController.timerModeLabel
                                                color: IslandController.timerMode === "focus" ? "#fda4af" : "#7dd3fc"
                                                font.pixelSize: 10
                                                font.weight: Font.DemiBold
                                            }
                                        }

                                        Item { Layout.fillWidth: true }

                                        // Circular Reset Button (Dynamic Notch style)
                                        Rectangle {
                                            width: 24
                                            height: 24
                                            radius: 12
                                            color: pomoResetMouse.containsMouse ? "#2d324a" : "#1e2235"
                                            border.color: "#333954"
                                            border.width: 1

                                            Image {
                                                anchors.centerIn: parent
                                                width: 12
                                                height: 12
                                                sourceSize: Qt.size(12, 12)
                                                source: "file://" + AppConfig.assetsDir + "/refresh.svg"
                                            }

                                            MouseArea {
                                                id: pomoResetMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: IslandController.resetTimer()
                                            }
                                        }
                                    }

                                    // Bottom Row: [Short Break] [Play/Pause] [Focus Time]
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 6

                                        // 1. Short Break Pill (5m)
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 26
                                            radius: 13
                                            color: IslandController.timerMode === "short_break"
                                                   ? "#0c4a6e"
                                                   : (sbMouse.containsMouse ? "#25293d" : "#1a1d2d")
                                            border.color: IslandController.timerMode === "short_break" ? "#38bdf8" : "#2b3048"
                                            border.width: 1

                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 4

                                                Image {
                                                    width: 11
                                                    height: 11
                                                    sourceSize: Qt.size(11, 11)
                                                    source: "file://" + AppConfig.assetsDir + "/coffee.svg"
                                                }

                                                Text {
                                                    text: "Short Break"
                                                    color: "#f8fafc"
                                                    font.pixelSize: 10
                                                    font.weight: Font.DemiBold
                                                }
                                            }

                                            MouseArea {
                                                id: sbMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: IslandController.setTimerMode("short_break")
                                            }
                                        }

                                        // 2. Center Play / Pause Pill (#ff4b55 accent color)
                                        Rectangle {
                                            width: 48
                                            height: 26
                                            radius: 13
                                            color: playPomoMouse.containsMouse
                                                   ? (IslandController.timerMode === "focus" ? "#e11d48" : "#0284c7")
                                                   : (IslandController.timerMode === "focus" ? "#ff4b55" : "#0ea5e9")

                                            Image {
                                                anchors.centerIn: parent
                                                width: 11
                                                height: 11
                                                sourceSize: Qt.size(11, 11)
                                                source: "file://" + AppConfig.assetsDir + (IslandController.timerRunning ? "/pause.svg" : "/play.svg")
                                            }

                                            MouseArea {
                                                id: playPomoMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: IslandController.toggleTimer()
                                            }
                                        }

                                        // 3. Focus Time Pill (25m)
                                        Rectangle {
                                            Layout.fillWidth: true
                                            height: 26
                                            radius: 13
                                            color: IslandController.timerMode === "focus"
                                                   ? "#3f1d2b"
                                                   : (ftMouse.containsMouse ? "#25293d" : "#1a1d2d")
                                            border.color: IslandController.timerMode === "focus" ? "#ff5a6e" : "#2b3048"
                                            border.width: 1

                                            RowLayout {
                                                anchors.centerIn: parent
                                                spacing: 4

                                                Image {
                                                    width: 11
                                                    height: 11
                                                    sourceSize: Qt.size(11, 11)
                                                    source: "file://" + AppConfig.assetsDir + "/target.svg"
                                                }

                                                Text {
                                                    text: "Focus Time"
                                                    color: "#f8fafc"
                                                    font.pixelSize: 10
                                                    font.weight: Font.DemiBold
                                                }
                                            }

                                            MouseArea {
                                                id: ftMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: IslandController.setTimerMode("focus")
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Mute button card
                        Rectangle {
                            width: 50
                            Layout.fillHeight: true
                            radius: 12
                            color: muteMouse.containsMouse ? "#27272a" : "#121217"
                            border.color: IslandController.isMuted ? "#ef4444" : "#22222a"
                            border.width: 1

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 4
                                Image {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 15
                                    height: 15
                                    source: IslandController.isMuted
                                            ? "file://" + AppConfig.assetsDir + "/volume-mute.svg"
                                            : "file://" + AppConfig.assetsDir + "/volume-high.svg"
                                }
                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: IslandController.isMuted ? "Muted" : (IslandController.volumePercent + "%")
                                    color: IslandController.isMuted ? "#ef4444" : "#94a3b8"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
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
            // PAGE 1: PEMUTAR MUSIK + 520px SPLIT SYNCED LYRICS KARAOKE
            // -----------------------------------------------------------------
            Item {
                id: pageMusic
                width: pageContainer.width
                height: pageContainer.height
                y: 0

                // When media exists: Split-capable RowLayout
                RowLayout {
                    anchors.fill: parent
                    spacing: 12
                    visible: IslandController.mediaHasTrack

                    // --- LEFT COLUMN: MUSIC PLAYER CONTROLS ---
                    ColumnLayout {
                        Layout.fillWidth: !IslandController.lyricsModeActive
                        Layout.preferredWidth: IslandController.lyricsModeActive ? 215 : -1
                        Layout.fillHeight: true
                        spacing: 8

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

                        // Seek timeline (Elapsed on left, -Remaining on right modern style!)
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Rectangle {
                                id: hubProgressBar
                                Layout.fillWidth: true
                                height: 6
                                radius: 3
                                color: "#27272a"

                                // Active progress fill
                                Rectangle {
                                    width: Math.max(0, Math.min(hubProgressBar.width, hubProgressBar.width * (seekMouseArea.isDragging ? seekMouseArea.dragRatio : IslandController.mediaPositionRatio)))
                                    height: parent.height
                                    radius: parent.radius
                                    color: IslandController.mediaAccentColor || "#38bdf8"
                                }

                                // Glowing scrubber thumb indicator on hover / drag
                                Rectangle {
                                    x: Math.max(0, Math.min(hubProgressBar.width - width, (hubProgressBar.width * (seekMouseArea.isDragging ? seekMouseArea.dragRatio : IslandController.mediaPositionRatio)) - width / 2))
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: (seekMouseArea.containsMouse || seekMouseArea.isDragging) ? 12 : 0
                                    height: width
                                    radius: width / 2
                                    color: "#ffffff"
                                    border.color: IslandController.mediaAccentColor || "#38bdf8"
                                    border.width: 2
                                    opacity: width > 0 ? 1.0 : 0.0

                                    Behavior on width { NumberAnimation { duration: 100 } }
                                    Behavior on opacity { NumberAnimation { duration: 100 } }
                                }

                                MouseArea {
                                    id: seekMouseArea
                                    anchors.fill: parent
                                    anchors.topMargin: -8
                                    anchors.bottomMargin: -8
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true

                                    property bool isDragging: false
                                    property real dragRatio: 0.0

                                    function calcRatio(mouseX) {
                                        return Math.max(0.0, Math.min(1.0, mouseX / width))
                                    }

                                    onPressed: (mouse) => {
                                        isDragging = true
                                        dragRatio = calcRatio(mouse.x)
                                        IslandController.mediaSeek(dragRatio)
                                    }
                                    onPositionChanged: (mouse) => {
                                        if (pressed && isDragging) {
                                            dragRatio = calcRatio(mouse.x)
                                            IslandController.mediaSeek(dragRatio)
                                        }
                                    }
                                    onReleased: (mouse) => {
                                        if (isDragging) {
                                            dragRatio = calcRatio(mouse.x)
                                            IslandController.mediaSeek(dragRatio)
                                            isDragging = false
                                        }
                                    }
                                    onCanceled: {
                                        isDragging = false
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: IslandController.mediaPositionFormatted
                                    color: "#94a3b8"
                                    font.pixelSize: 9
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: IslandController.mediaRemainingFormatted
                                    color: "#94a3b8"
                                    font.pixelSize: 9
                                }
                            }
                        }

                        // Media playback buttons (Symmetrical Left-Center-Right layout)
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            // 1. LEFT: Lyrics Button (Vector SVG icon, Pill when off, Active Circle when on)
                            Rectangle {
                                height: 30
                                radius: 15
                                implicitWidth: IslandController.lyricsModeActive ? 30 : 62
                                color: IslandController.lyricsModeActive
                                       ? "#162436"
                                       : (lyricsBtnMouse.containsMouse ? "#2f313f" : "#1a1b24")
                                border.color: IslandController.lyricsModeActive
                                              ? (IslandController.mediaAccentColor || "#38bdf8")
                                              : (lyricsBtnMouse.containsMouse ? "#475569" : "#282937")
                                border.width: IslandController.lyricsModeActive ? 1.5 : 1

                                Behavior on implicitWidth { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
                                Behavior on color { ColorAnimation { duration: 150 } }

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 5

                                    Image {
                                        width: 14
                                        height: 14
                                        source: "file://" + AppConfig.assetsDir + "/lyrics.svg"
                                        sourceSize.width: 14
                                        sourceSize.height: 14
                                        opacity: IslandController.lyricsModeActive ? 1.0 : 0.85
                                    }

                                    Text {
                                        visible: !IslandController.lyricsModeActive
                                        text: "Lirik"
                                        color: "#f8fafc"
                                        font.pixelSize: 10
                                        font.weight: Font.DemiBold
                                    }
                                }

                                MouseArea {
                                    id: lyricsBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: IslandController.toggleLyricsMode()
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // 2. CENTER: Transport Controls [Prev] [Play/Pause] [Next]
                            RowLayout {
                                spacing: 8

                                // Previous
                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: mPrevMouse.containsMouse ? "#2f313f" : "#1a1b24"
                                    border.color: mPrevMouse.containsMouse ? "#475569" : "#282937"
                                    border.width: 1

                                    Image {
                                        anchors.centerIn: parent
                                        width: 13
                                        height: 13
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

                                // Play / Pause
                                Rectangle {
                                    width: 38
                                    height: 38
                                    radius: 19
                                    color: mPlayMouse.containsMouse ? "#0284c7" : "#0ea5e9"

                                    Image {
                                        anchors.centerIn: parent
                                        width: 15
                                        height: 15
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

                                // Next
                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: mNextMouse.containsMouse ? "#2f313f" : "#1a1b24"
                                    border.color: mNextMouse.containsMouse ? "#475569" : "#282937"
                                    border.width: 1

                                    Image {
                                        anchors.centerIn: parent
                                        width: 13
                                        height: 13
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
                            }

                            Item { Layout.fillWidth: true }

                            // 3. RIGHT: Volume Button (+ Slider when in full 420px view, Circle Mute toggle when in 520px Split Lyrics view)
                            RowLayout {
                                spacing: 6

                                Rectangle {
                                    width: 30
                                    height: 30
                                    radius: 15
                                    color: volBtnMouse.containsMouse ? "#2f313f" : "#1a1b24"
                                    border.color: IslandController.isMuted ? "#ef4444" : (volBtnMouse.containsMouse ? "#475569" : "#282937")
                                    border.width: 1

                                    Image {
                                        anchors.centerIn: parent
                                        width: 14
                                        height: 14
                                        source: IslandController.isMuted
                                                ? "file://" + AppConfig.assetsDir + "/volume-mute.svg"
                                                : "file://" + AppConfig.assetsDir + "/volume-high.svg"
                                    }

                                    MouseArea {
                                        id: volBtnMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: IslandController.toggleMute()
                                    }
                                }

                                Rectangle {
                                    id: hubVolBar
                                    visible: !IslandController.lyricsModeActive
                                    width: 58
                                    height: 5
                                    radius: 2.5
                                    color: "#27272a"
                                    Rectangle {
                                        width: hubVolBar.width * IslandController.volume
                                        height: parent.height
                                        radius: parent.radius
                                        color: IslandController.isMuted ? "#ef4444" : (IslandController.mediaAccentColor || "#38bdf8")
                                    }
                                    MouseArea {
                                        id: hubVolBarMouse
                                        anchors.fill: parent
                                        anchors.topMargin: -6
                                        anchors.bottomMargin: -6
                                        cursorShape: Qt.PointingHandCursor
                                        onPressed: (mouse) => {
                                            var r = Math.max(0.0, Math.min(1.0, mouse.x / width))
                                            IslandController.setVolume(r)
                                        }
                                        onPositionChanged: (mouse) => {
                                            if (pressed) {
                                                var r = Math.max(0.0, Math.min(1.0, mouse.x / width))
                                                IslandController.setVolume(r)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Dedicated full-width Volume Bar when Lyrics Mode is open
                        Rectangle {
                            visible: IslandController.lyricsModeActive
                            Layout.fillWidth: true
                            height: 24
                            radius: 12
                            color: "#13151f"
                            border.color: "#232636"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 9
                                anchors.rightMargin: 9
                                spacing: 7

                                Image {
                                    width: 12
                                    height: 12
                                    source: IslandController.isMuted
                                            ? "file://" + AppConfig.assetsDir + "/volume-mute.svg"
                                            : "file://" + AppConfig.assetsDir + "/volume-high.svg"
                                    opacity: 0.85

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: IslandController.toggleMute()
                                    }
                                }

                                Rectangle {
                                    id: lyricsVolSlider
                                    Layout.fillWidth: true
                                    height: 5
                                    radius: 2.5
                                    color: "#27272a"

                                    Rectangle {
                                        width: Math.max(0, Math.min(lyricsVolSlider.width, lyricsVolSlider.width * IslandController.volume))
                                        height: parent.height
                                        radius: parent.radius
                                        color: IslandController.isMuted ? "#ef4444" : (IslandController.mediaAccentColor || "#38bdf8")
                                    }

                                    Rectangle {
                                        x: Math.max(0, Math.min(lyricsVolSlider.width - width, (lyricsVolSlider.width * IslandController.volume) - width / 2))
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: (lyricsVolMouse.containsMouse || lyricsVolMouse.pressed) ? 11 : 7
                                        height: width
                                        radius: width / 2
                                        color: "#ffffff"
                                        border.color: IslandController.isMuted ? "#ef4444" : (IslandController.mediaAccentColor || "#38bdf8")
                                        border.width: 2

                                        Behavior on width { NumberAnimation { duration: 100 } }
                                    }

                                    MouseArea {
                                        id: lyricsVolMouse
                                        anchors.fill: parent
                                        anchors.topMargin: -8
                                        anchors.bottomMargin: -8
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onPressed: (mouse) => {
                                            var r = Math.max(0.0, Math.min(1.0, mouse.x / width))
                                            IslandController.setVolume(r)
                                        }
                                        onPositionChanged: (mouse) => {
                                            if (pressed) {
                                                var r = Math.max(0.0, Math.min(1.0, mouse.x / width))
                                                IslandController.setVolume(r)
                                            }
                                        }
                                    }
                                }

                                Text {
                                    text: IslandController.isMuted ? "Mute" : (IslandController.volumePercent + "%")
                                    color: IslandController.isMuted ? "#ef4444" : "#94a3b8"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                    Layout.preferredWidth: 26
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }

                    // --- VERTICAL DIVIDER (x=252px split line) ---
                    Rectangle {
                        visible: IslandController.lyricsModeActive
                        width: 1
                        Layout.fillHeight: true
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                        color: "#262b40"
                    }

                    // --- RIGHT COLUMN: SYNCED LYRICS KARAOKE VIEW ---
                    Item {
                        visible: IslandController.lyricsModeActive
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        HoverHandler {
                            id: lyricsPanelHover
                        }

                        ListView {
                            id: lyricsList
                            anchors.fill: parent
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4
                            spacing: 6
                            clip: true
                            model: IslandController.lyricsLines
                            currentIndex: Math.max(0, IslandController.currentLyricIndex)

                            preferredHighlightBegin: height * 0.34
                            preferredHighlightEnd: height * 0.56
                            highlightRangeMode: ListView.ApplyRange
                            highlightMoveDuration: 380

                            delegate: Rectangle {
                                id: lyricDelegate
                                required property var modelData
                                required property int index

                                width: lyricsList.width
                                height: lyricTxt.implicitHeight + 8
                                radius: 6
                                color: lyricDelegate.isActive
                                       ? Qt.rgba(1, 1, 1, 0.09)
                                       : (lyricMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.04) : "transparent")

                                readonly property bool isActive: index === IslandController.currentLyricIndex
                                readonly property bool isNear: Math.abs(index - IslandController.currentLyricIndex) === 1

                                // Active left accent indicator bar
                                Rectangle {
                                    visible: lyricDelegate.isActive
                                    anchors.left: parent.left
                                    anchors.leftMargin: 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 3
                                    height: Math.max(12, parent.height - 8)
                                    radius: 1.5
                                    color: IslandController.mediaAccentColor || "#38bdf8"
                                }

                                Text {
                                    id: lyricTxt
                                    anchors.left: parent.left
                                    anchors.leftMargin: lyricDelegate.isActive ? 10 : 6
                                    anchors.right: parent.right
                                    anchors.rightMargin: 4
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: lyricDelegate.modelData.text || ""
                                    wrapMode: Text.WordWrap
                                    color: {
                                        if (lyricDelegate.isActive) return "#ffffff";
                                        if (lyricMouse.containsMouse) return "#38bdf8";
                                        if (lyricDelegate.isNear) return "#cbd5e1";
                                        return "#8b9bb4";
                                    }
                                    font.pixelSize: lyricDelegate.isActive ? 13 : 11
                                    font.weight: lyricDelegate.isActive ? Font.ExtraBold : Font.DemiBold
                                    transformOrigin: Item.Left
                                    scale: lyricDelegate.isActive ? 1.0 : 0.96

                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                                    Behavior on anchors.leftMargin { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
                                }

                                // Click any lyric line to jump/seek to that timestamp!
                                MouseArea {
                                    id: lyricMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (lyricDelegate.modelData.time !== undefined) {
                                            IslandController.seekToLyricTime(lyricDelegate.modelData.time)
                                        }
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
                        text: "Putar lagu di Spotify atau video di browser untuk kendali & lirik karaoke"
                        color: "#64748b"
                        font.pixelSize: 10
                    }
                }
            }

            // -----------------------------------------------------------------
            // PAGE 2: PINTASAN CEPAT (QUICK TOOLS + BRIGHTNESS & MIC CONTROL)
            // -----------------------------------------------------------------
            Item {
                id: pageTools
                width: pageContainer.width
                height: pageContainer.height
                y: 0

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 6

                    // Top Bar: Interactive Screen Brightness Slider
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: 10
                        color: "#121217"
                        border.color: "#22222a"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            Image {
                                width: 14
                                height: 14
                                sourceSize: Qt.size(14, 14)
                                source: "file://" + AppConfig.assetsDir + "/sun.svg"
                            }

                            Text {
                                text: "Kecerahan"
                                color: "#cbd5e1"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }

                            Item {
                                id: brightnessSliderWrap
                                Layout.fillWidth: true
                                height: 18

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 6
                                    radius: 3
                                    color: "#272732"

                                    Rectangle {
                                        width: parent.width * Math.min(1.0, Math.max(0.05, IslandController.brightnessPercent / 100.0))
                                        height: parent.height
                                        radius: 3
                                        color: "#facc15"

                                        Behavior on width {
                                            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: brightnessSliderMouse
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: (mouse) => {
                                        var r = Math.max(0.05, Math.min(1.0, mouse.x / width))
                                        IslandController.setBrightness(r)
                                    }
                                    onPositionChanged: (mouse) => {
                                        if (pressed) {
                                            var r = Math.max(0.05, Math.min(1.0, mouse.x / width))
                                            IslandController.setBrightness(r)
                                        }
                                    }
                                }
                            }

                            Text {
                                text: IslandController.brightnessPercent + "%"
                                color: "#facc15"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                Layout.preferredWidth: 30
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }

                    // Middle Bar: Live Weather & Day Progress Bar (Fase 4)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: 10
                        color: weatherCardMouse.containsMouse ? "#181a24" : "#121217"
                        border.color: weatherCardMouse.containsMouse ? "#38bdf8" : "#22222a"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            // Weather Section
                            RowLayout {
                                spacing: 5
                                Image {
                                    width: 14
                                    height: 14
                                    sourceSize: Qt.size(14, 14)
                                    source: "file://" + AppConfig.assetsDir + "/" + (IslandController.weatherIcon ? (IslandController.weatherIcon.indexOf(".svg") !== -1 ? IslandController.weatherIcon : (IslandController.weatherIcon + ".svg")) : "cloud.svg")
                                }

                                Text {
                                    text: Math.round(IslandController.weatherTemperature) + "°C"
                                    color: "#f8fafc"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                }

                                Text {
                                    text: IslandController.weatherCondition || "Memuat..."
                                    color: "#94a3b8"
                                    font.pixelSize: 9
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                    Layout.maximumWidth: 100
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // Vertical divider
                            Rectangle {
                                width: 1
                                height: 14
                                color: "#22222a"
                            }

                            // Day Progress Section
                            RowLayout {
                                spacing: 6

                                Text {
                                    text: "Hari"
                                    color: "#64748b"
                                    font.pixelSize: 9
                                    font.weight: Font.Medium
                                }

                                Rectangle {
                                    width: 50
                                    height: 5
                                    radius: 2.5
                                    color: "#272732"

                                    Rectangle {
                                        width: parent.width * Math.min(1.0, Math.max(0.02, IslandController.dayProgressPercent / 100.0))
                                        height: parent.height
                                        radius: 2.5
                                        color: "#38bdf8"
                                    }
                                }

                                Text {
                                    text: IslandController.dayProgressPercent + "%"
                                    color: "#38bdf8"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        MouseArea {
                            id: weatherCardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: pageContainer.goTo(3, 1)
                        }
                    }

                    // Bottom Grid: 6 Proportional Quick Tools (3x2)
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 3
                        rowSpacing: 6
                        columnSpacing: 6

                        // 1. Screenshot Tool
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 1
                            radius: 10
                            clip: true
                            color: ssMouse.containsMouse ? "#20202c" : "#121217"
                            border.color: "#22222a"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 7
                                Image {
                                    Layout.preferredWidth: 16
                                    Layout.preferredHeight: 16
                                    sourceSize: Qt.size(16, 16)
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
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 1
                            radius: 10
                            clip: true
                            color: nlMouse.containsMouse ? "#20202c" : "#121217"
                            border.color: IslandController.nightLightActive ? "#818cf8" : "#22222a"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 7
                                Image {
                                    Layout.preferredWidth: 16
                                    Layout.preferredHeight: 16
                                    sourceSize: Qt.size(16, 16)
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

                        // 3. Microphone Mute Toggle
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 1
                            radius: 10
                            clip: true
                            color: micMouse.containsMouse ? "#20202c" : "#121217"
                            border.color: IslandController.micMuted ? "#f43f5e" : "#22222a"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 7
                                Image {
                                    width: 15
                                    height: 15
                                    sourceSize: Qt.size(15, 15)
                                    source: "file://" + AppConfig.assetsDir + (IslandController.micMuted ? "/mic-off.svg" : "/mic.svg")
                                }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: "Mikrofon"; color: "#f8fafc"; font.pixelSize: 11; font.weight: Font.DemiBold }
                                    Text {
                                        text: IslandController.micMuted ? "Dibisukan" : ("Aktif · " + IslandController.micPercent + "%")
                                        color: IslandController.micMuted ? "#f43f5e" : "#34d399"
                                        font.pixelSize: 9
                                    }
                                }
                            }

                            MouseArea {
                                id: micMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: IslandController.toggleMicMute()
                            }
                        }

                        // 4. Lock Screen
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 1
                            radius: 10
                            clip: true
                            color: lockMouse.containsMouse ? "#20202c" : "#121217"
                            border.color: "#22222a"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 7
                                Image {
                                    Layout.preferredWidth: 16
                                    Layout.preferredHeight: 16
                                    sourceSize: Qt.size(16, 16)
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

                        // 5. Cermin Kamera (Webcam Mirror Preview - Fase 4)
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 1
                            radius: 10
                            clip: true
                            color: camMouse.containsMouse ? "#20202c" : "#121217"
                            border.color: camMouse.containsMouse ? "#a855f7" : "#22222a"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 7
                                Image {
                                    Layout.preferredWidth: 16
                                    Layout.preferredHeight: 16
                                    sourceSize: Qt.size(16, 16)
                                    source: "file://" + AppConfig.assetsDir + "/video.svg"
                                }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: "Cermin Kamera"; color: "#f8fafc"; font.pixelSize: 11; font.weight: Font.DemiBold }
                                    Text { text: "Webcam Notch"; color: "#a855f7"; font.pixelSize: 9 }
                                }
                            }

                            MouseArea {
                                id: camMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    IslandController.collapse()
                                    IslandController.openCameraMirror()
                                }
                            }
                        }

                        // 6. Bluetooth / Charging Peek Demo (Left-click: TWS Peek, Right-click: Charging Peek)
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 1
                            radius: 10
                            clip: true
                            color: peekMouse.containsMouse ? "#20202c" : "#121217"
                            border.color: IslandController.btDeviceConnected ? "#5ec2ff" : "#22222a"
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 7
                                Image {
                                    width: 15
                                    height: 15
                                    sourceSize: Qt.size(15, 15)
                                    source: "file://" + AppConfig.assetsDir + "/headphones.svg"
                                }
                                ColumnLayout {
                                    spacing: 0
                                    Text { text: "Bluetooth"; color: "#f8fafc"; font.pixelSize: 11; font.weight: Font.DemiBold }
                                    Text {
                                        text: IslandController.btDeviceConnected ? ("Aktif · " + IslandController.btDeviceBattery + "%") : "Menu / Klik Kanan"
                                        color: IslandController.btDeviceConnected ? "#5ec2ff" : "#64748b"
                                        font.pixelSize: 9
                                    }
                                }
                            }

                            MouseArea {
                                id: peekMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: (mouse) => {
                                    if (mouse.button === Qt.RightButton) {
                                        IslandController.collapse()
                                        IslandController.triggerTestBluetoothPeek()
                                    } else {
                                        pageContainer.goTo(5, 1)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // -----------------------------------------------------------------
            // PAGE 3: CUACA & HARI INI (DEDICATED WEATHER & DAY CYCLE VIEW)
            // -----------------------------------------------------------------
            PageWeather {
                id: pageWeather
                width: pageContainer.width
                height: pageContainer.height
                y: 0
            }

            // -----------------------------------------------------------------
            // PAGE 4: HARDWARE, SUHU, TDP & JARINGAN
            // -----------------------------------------------------------------
            PageHardware {
                id: pageNet
                width: pageContainer.width
                height: pageContainer.height
                y: 0
            }

            // -----------------------------------------------------------------
            // PAGE 5: BLUETOOTH & PERANGKAT TERKONEKSI
            // -----------------------------------------------------------------
            PageBluetooth {
                id: pageBluetooth
                width: pageContainer.width
                height: pageContainer.height
                y: 0
            }

            // -----------------------------------------------------------------
            // PAGE 5: PUSAT NOTIFIKASI (NOTIFICATION CENTER & READER)
            // -----------------------------------------------------------------
            PageNotifications {
                id: pageNotifications
                width: pageContainer.width
                height: pageContainer.height
                y: 0
            }

            // -----------------------------------------------------------------
            // PAGE 4: KESEHATAN & PELACAK AIR (WITH HOURLY HISTOGRAM CHART)
            // -----------------------------------------------------------------
            PageHealth {
                id: pageHealth
                width: pageContainer.width
                height: pageContainer.height
                y: 0
            }

            // -----------------------------------------------------------------
            // PAGE 5: DAFTAR TUGAS (TO-DO)
            // -----------------------------------------------------------------
            PageTodo {
                id: pageTodo
                width: pageContainer.width
                height: pageContainer.height
                y: 0
            }

            // -----------------------------------------------------------------
            // PAGE 6: RAK FILE SEMENTARA (WAYLAND FILE SHELF)
            // -----------------------------------------------------------------
            PageShelf {
                id: pageShelf
                width: pageContainer.width
                height: pageContainer.height
                y: 0
            }
        }

        // =====================================================================
        // DEDICATED SEPARATE SETTINGS VIEW (Completely isolated from carousel)
        // =====================================================================
        Item {
            id: settingsContainer
            visible: root.isSettingsOpen
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            focus: root.isSettingsOpen
            Keys.onEscapePressed: IslandController.closeSettingsView()

            PageSettings {
                id: pageSettings
                anchors.fill: parent
            }
        }
    }
}
