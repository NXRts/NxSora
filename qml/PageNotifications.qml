import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property var currentItem: IslandController.selectedNotif
    readonly property bool hasItems: IslandController.notifTotalCount > 0
    readonly property bool isDnd: IslandController.notifDndEnabled
    property bool copiedFeedback: false

    // Smart check: is the title distinct from the app name and body?
    readonly property bool hasDistinctTitle: {
        if (!root.hasItems) return false;
        var appStr = String(root.currentItem.app || "").trim().toLowerCase();
        var titleStr = String(root.currentItem.title || "").trim().toLowerCase();
        var bodyStr = String(root.currentItem.body || "").trim().toLowerCase();
        return titleStr !== "" && titleStr !== appStr && titleStr !== bodyStr;
    }

    Timer {
        id: copyFeedbackTimer
        interval: 1500
        repeat: false
        onTriggered: root.copiedFeedback = false
    }

    function categoryColor(cat) {
        switch (String(cat || "system")) {
            case "chat": return "#34d399";
            case "media": return "#c084fc";
            case "thermal": return "#f59e0b";
            case "focus": return "#fb7185";
            case "browser": return "#38bdf8";
            default: return "#818cf8";
        }
    }

    function categoryIcon(cat) {
        switch (String(cat || "system")) {
            case "chat": return "💬";
            case "media": return "🎵";
            case "thermal": return "⚡";
            case "focus": return "🎯";
            case "browser": return "🌐";
            default: return "🔔";
        }
    }

    function previewTextFor(item) {
        if (!item) return "";
        var appStr = String(item.app || "").trim();
        var titleStr = String(item.title || "").trim();
        var bodyStr = String(item.body || "").trim().replace(/\n+/g, " ");
        if (titleStr === "" || titleStr.toLowerCase() === appStr.toLowerCase()) {
            return bodyStr !== "" ? bodyStr : titleStr;
        }
        return titleStr;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // =====================================================================
        // 1. LEFT CARD: INBOX LIST + DND & CLEAR CONTROLS (164px Strict Width)
        // =====================================================================
        Rectangle {
            Layout.preferredWidth: 164
            Layout.minimumWidth: 164
            Layout.maximumWidth: 164
            Layout.fillHeight: true
            radius: 12
            clip: true
            color: "#121217"
            border.color: "#22222a"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                // Top Header Bar: [Masuk + Badge] [DND] [+] [Hapus]
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    spacing: 4

                    Text {
                        text: "Masuk"
                        color: "#f8fafc"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }

                    // Unread / Total Count Badge
                    Rectangle {
                        Layout.preferredWidth: Math.max(18, cntTxt.implicitWidth + 8)
                        Layout.preferredHeight: 16
                        radius: 8
                        color: IslandController.notifUnreadCount > 0 ? "#251e4a" : "#1c1c28"
                        border.color: IslandController.notifUnreadCount > 0 ? "#818cf8" : "#334155"
                        border.width: 1

                        Text {
                            id: cntTxt
                            anchors.centerIn: parent
                            text: String(IslandController.notifTotalCount)
                            color: IslandController.notifUnreadCount > 0 ? "#c7d2fe" : "#94a3b8"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // DND Toggle Button (🔕 Mode Fokus / Jangan Ganggu)
                    Rectangle {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 20
                        radius: 6
                        color: root.isDnd ? "#3b2313" : (dndMouse.containsMouse ? "#232332" : "#181822")
                        border.color: root.isDnd ? "#f59e0b" : "#2d2d3c"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.isDnd ? "🔕" : "🔔"
                            font.pixelSize: 9
                        }

                        MouseArea {
                            id: dndMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.toggleNotifDnd()
                        }
                    }

                    // Add Demo Notification Button (+)
                    Rectangle {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 20
                        radius: 6
                        color: testMouse.containsMouse ? "#252538" : "#181822"
                        border.color: "#2d2d3c"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: "#818cf8"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: testMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.triggerTestNotification()
                        }
                    }

                    // Clear All Button (Clean vector trash/clear icon)
                    Rectangle {
                        visible: root.hasItems
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 20
                        radius: 6
                        color: clrMouse.containsMouse ? "#381822" : "#181822"
                        border.color: clrMouse.containsMouse ? "#f43f5e" : "#2d2d3c"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "🗑"
                            color: clrMouse.containsMouse ? "#fda4af" : "#94a3b8"
                            font.pixelSize: 9
                        }

                        MouseArea {
                            id: clrMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.clearNotifications()
                        }
                    }
                }

                // Scrollable Notification History List (Strictly bounded inside 148px inner width)
                ListView {
                    id: notifListView
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    clip: true
                    spacing: 5
                    model: IslandController.notifHistory

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        readonly property bool isSelected: index === IslandController.notifSelectedIndex
                        readonly property bool isUnread: Boolean(modelData.unread)
                        readonly property color catClr: root.categoryColor(modelData.category)

                        width: notifListView.width
                        height: 44
                        radius: 9
                        clip: true
                        color: isSelected
                               ? "#1b1d30"
                               : (rowMouse.containsMouse ? "#191924" : "#16161f")
                        border.color: isSelected ? catClr : (isUnread ? "#4f46e5" : "#242432")
                        border.width: isSelected ? 1.3 : 1

                        // Left Unread Accent Strip
                        Rectangle {
                            visible: isUnread
                            width: 3
                            height: parent.height - 12
                            radius: 1.5
                            x: 3
                            anchors.verticalCenter: parent.verticalCenter
                            color: "#818cf8"
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.leftMargin: isUnread ? 9 : 8
                            anchors.rightMargin: 8
                            anchors.topMargin: 5
                            anchors.bottomMargin: 5
                            spacing: 2

                            // Top Row: Category Icon + App Name + Time
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                Text {
                                    text: root.categoryIcon(modelData.category)
                                    font.pixelSize: 9
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.minimumWidth: 0
                                    text: String(modelData.app || "Sistem")
                                    color: catClr
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                Text {
                                    text: String(modelData.time || "")
                                    color: "#64748b"
                                    font.pixelSize: 8
                                    font.weight: Font.DemiBold
                                }
                            }

                            // Bottom Row: Meaningful Preview Text (Never duplicates App Name)
                            Text {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                text: root.previewTextFor(modelData)
                                color: isSelected || isUnread ? "#f8fafc" : "#cbd5e1"
                                font.pixelSize: 10
                                font.weight: isSelected || isUnread ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }
                        }

                        MouseArea {
                            id: rowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.copiedFeedback = false
                                IslandController.selectNotification(index)
                            }
                        }
                    }

                    // Empty Inbox State
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: !root.hasItems
                        spacing: 4

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "🔕"
                            font.pixelSize: 16
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Kotak masuk kosong"
                            color: "#64748b"
                            font.pixelSize: 9
                        }
                    }
                }
            }
        }

        // =====================================================================
        // 2. RIGHT CARD: FULL NOTIFICATION MESSAGE READER
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            radius: 12
            clip: true
            color: "#121217"
            border.color: root.hasItems
                          ? Qt.rgba(root.categoryColor(root.currentItem.category).r,
                                    root.categoryColor(root.currentItem.category).g,
                                    root.categoryColor(root.currentItem.category).b, 0.42)
                          : "#22222a"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 9
                spacing: 6

                // Reader Top Header: [Category Icon + App Name + Time] [Salin] [✕]
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        radius: 13
                        color: "#1a1b28"
                        border.color: root.categoryColor(root.currentItem.category)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.categoryIcon(root.currentItem.category)
                            font.pixelSize: 11
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.minimumWidth: 0
                        spacing: 1

                        Text {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            text: root.hasItems ? String(root.currentItem.app || "Sistem") : "Pusat Notifikasi"
                            color: "#f8fafc"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        Text {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            text: root.isDnd
                                  ? "🔕 Mode Jangan Ganggu Aktif"
                                  : (root.hasItems ? ("Pukul " + String(root.currentItem.time || "--:--")) : "Tidak ada pesan")
                            color: root.isDnd ? "#f59e0b" : root.categoryColor(root.currentItem.category)
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    // Copy Message Button (📋 Salin)
                    Rectangle {
                        visible: root.hasItems
                        Layout.preferredWidth: copyLbl.implicitWidth + 14
                        Layout.preferredHeight: 22
                        radius: 7
                        color: root.copiedFeedback
                               ? "#122b22"
                               : (copyMouse.containsMouse ? "#24263a" : "#191a26")
                        border.color: root.copiedFeedback ? "#34d399" : "#32344a"
                        border.width: 1

                        Text {
                            id: copyLbl
                            anchors.centerIn: parent
                            text: root.copiedFeedback ? "✓ Disalin" : "Salin"
                            color: root.copiedFeedback ? "#34d399" : "#e2e8f0"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: copyMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (IslandController.copySelectedNotification()) {
                                    root.copiedFeedback = true
                                    copyFeedbackTimer.restart()
                                }
                            }
                        }
                    }

                    // Delete Single Notification Button (✕)
                    Rectangle {
                        visible: root.hasItems
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        radius: 7
                        color: delOneMouse.containsMouse ? "#381822" : "#191a26"
                        border.color: delOneMouse.containsMouse ? "#f43f5e" : "#32344a"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: delOneMouse.containsMouse ? "#fda4af" : "#94a3b8"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: delOneMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.removeNotification(IslandController.notifSelectedIndex)
                        }
                    }
                }

                // Full Message Content Box (Clean, High-Contrast & Scrollable)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    radius: 9
                    clip: true
                    color: "#171721"
                    border.color: "#242434"
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 9
                        spacing: 5

                        // Show Title ONLY if it's distinct from the App Name (avoids repeating "Antigravity" twice!)
                        Text {
                            visible: root.hasDistinctTitle
                            Layout.fillWidth: true
                            text: String(root.currentItem.title || "")
                            color: "#ffffff"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }

                        Rectangle {
                            visible: root.hasDistinctTitle
                            Layout.fillWidth: true
                            height: 1
                            color: "#262638"
                        }

                        // Scrollable Full Message Body
                        Flickable {
                            id: bodyFlick
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentWidth: width
                            contentHeight: fullBodyTxt.implicitHeight
                            clip: true
                            boundsBehavior: Flickable.StopAtBounds

                            Text {
                                id: fullBodyTxt
                                width: bodyFlick.width
                                text: {
                                    if (!root.hasItems) {
                                        return "Belum ada notifikasi yang masuk. Klik tombol '+' di kiri untuk menguji tampilan pesan panjang.";
                                    }
                                    var b = String(root.currentItem.body || "").trim();
                                    var t = String(root.currentItem.title || "").trim();
                                    return b !== "" ? b : t;
                                }
                                color: "#f1f5f9"
                                font.pixelSize: 11
                                font.weight: root.hasDistinctTitle ? Font.Normal : Font.DemiBold
                                wrapMode: Text.WordWrap
                                lineHeight: 1.28
                            }
                        }

                        // Bottom Footer inside Reader: Item Counter & Prev/Next Quick Step
                        RowLayout {
                            visible: IslandController.notifTotalCount > 1
                            Layout.fillWidth: true
                            spacing: 6

                            Text {
                                text: "Pesan " + (IslandController.notifSelectedIndex + 1) + " / " + IslandController.notifTotalCount
                                color: "#64748b"
                                font.pixelSize: 8
                                font.weight: Font.DemiBold
                            }

                            Item { Layout.fillWidth: true }

                            // Prev Notification (<)
                            Rectangle {
                                width: 18
                                height: 16
                                radius: 5
                                color: prevNotifMouse.containsMouse ? "#282a3e" : "#1e1f2e"
                                opacity: IslandController.notifSelectedIndex > 0 ? 1.0 : 0.4

                                Text {
                                    anchors.centerIn: parent
                                    text: "‹"
                                    color: "#cbd5e1"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }

                                MouseArea {
                                    id: prevNotifMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (IslandController.notifSelectedIndex > 0) {
                                            IslandController.selectNotification(IslandController.notifSelectedIndex - 1)
                                        }
                                    }
                                }
                            }

                            // Next Notification (>)
                            Rectangle {
                                width: 18
                                height: 16
                                radius: 5
                                color: nextNotifMouse.containsMouse ? "#282a3e" : "#1e1f2e"
                                opacity: IslandController.notifSelectedIndex < IslandController.notifTotalCount - 1 ? 1.0 : 0.4

                                Text {
                                    anchors.centerIn: parent
                                    text: "›"
                                    color: "#cbd5e1"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }

                                MouseArea {
                                    id: nextNotifMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (IslandController.notifSelectedIndex < IslandController.notifTotalCount - 1) {
                                            IslandController.selectNotification(IslandController.notifSelectedIndex + 1)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
