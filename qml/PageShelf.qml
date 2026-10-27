import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Shapes

Item {
    id: root

    property bool isDragHovering: false

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // =====================================================================
        // HEADER: TITLE + COUNT BADGE + DRAG ALL + CLEAR BUTTON
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                width: 22
                height: 22
                radius: 6
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: "#38bdf8" }
                    GradientStop { position: 1.0; color: "#6366f1" }
                }
                Text {
                    anchors.centerIn: parent
                    text: "📥"
                    font.pixelSize: 11
                }
            }

            Text {
                text: "Rak File (Shelf)"
                color: "#f8fafc"
                font.pixelSize: 12
                font.weight: Font.Bold
            }

            Rectangle {
                height: 20
                radius: 10
                color: "#1e293b"
                border.color: "#334155"
                border.width: 1
                implicitWidth: countTxt.implicitWidth + 14

                Text {
                    id: countTxt
                    anchors.centerIn: parent
                    text: IslandController.shelfCount + " Item"
                    color: "#38bdf8"
                    font.pixelSize: 9
                    font.weight: Font.Bold
                }
            }

            Item { Layout.fillWidth: true }

            // Drag All Out Button (visible when > 1 item)
            Rectangle {
                visible: IslandController.shelfCount > 1
                height: 22
                radius: 11
                implicitWidth: dragAllTxt.implicitWidth + 16
                color: dragAllMouse.containsMouse ? "#0284c7" : "#0c4a6e"
                border.color: "#38bdf8"
                border.width: 1

                Text {
                    id: dragAllTxt
                    anchors.centerIn: parent
                    text: "📤 Seret Semua"
                    color: "#f8fafc"
                    font.pixelSize: 9
                    font.weight: Font.Bold
                }

                MouseArea {
                    id: dragAllMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.OpenHandCursor
                    onPressed: IslandController.startShelfDragAll()
                }
            }

            // Clear Shelf Button (Nusa .sh-clear style)
            Rectangle {
                visible: IslandController.shelfCount > 0
                height: 22
                radius: 11
                implicitWidth: clearTxt.implicitWidth + 16
                color: clearMouse.containsMouse ? "#3f1d28" : "#1e293b"
                border.color: clearMouse.containsMouse ? "#f43f5e" : "#334155"
                border.width: 1

                Text {
                    id: clearTxt
                    anchors.centerIn: parent
                    text: "Bersihkan"
                    color: clearMouse.containsMouse ? "#fda4af" : "#94a3b8"
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.clearShelf()
                }
            }
        }

        // =====================================================================
        // DROP ZONE & STASHED FILE CARDS (NUSA .sh-zone & .sh-card STYLE)
        // =====================================================================
        Item {
            id: shelfZoneContainer
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Background & Dashed Border
            Rectangle {
                anchors.fill: parent
                radius: 14
                color: root.isDragHovering ? "#131c31" : "#10121c"
                Behavior on color { ColorAnimation { duration: 180 } }
            }

            Shape {
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    fillColor: "transparent"
                    strokeColor: root.isDragHovering ? "#38bdf8" : (IslandController.shelfCount > 0 ? "#24293d" : "#334155")
                    strokeWidth: root.isDragHovering ? 2.0 : 1.4
                    strokeStyle: ShapePath.DashLine
                    dashPattern: [4, 4]

                    startX: 14; startY: 1
                    PathLine { x: shelfZoneContainer.width - 14; y: 1 }
                    PathArc { x: shelfZoneContainer.width - 1; y: 14; radiusX: 13; radiusY: 13 }
                    PathLine { x: shelfZoneContainer.width - 1; y: shelfZoneContainer.height - 14 }
                    PathArc { x: shelfZoneContainer.width - 14; y: shelfZoneContainer.height - 1; radiusX: 13; radiusY: 13 }
                    PathLine { x: 14; y: shelfZoneContainer.height - 1 }
                    PathArc { x: 1; y: shelfZoneContainer.height - 14; radiusX: 13; radiusY: 13 }
                    PathLine { x: 1; y: 14 }
                    PathArc { x: 14; y: 1; radiusX: 13; radiusY: 13 }
                }
            }

            // 1. HORIZONTAL FILE CARDS LIST (when Shelf has files)
            ListView {
                id: shelfList
                anchors.fill: parent
                anchors.margins: 10
                orientation: ListView.Horizontal
                spacing: 10
                clip: true
                visible: IslandController.shelfCount > 0
                opacity: root.isDragHovering ? 0.25 : 1.0
                Behavior on opacity { NumberAnimation { duration: 150 } }

                model: IslandController.shelfItems

                delegate: Rectangle {
                    id: fileCard
                    required property var modelData
                    required property int index

                    width: 84
                    height: shelfList.height
                    radius: 11
                    color: cardMouse.containsMouse ? "#1b2033" : "#151826"
                    border.color: cardMouse.containsMouse ? "#38bdf8" : "#24293e"
                    border.width: 1

                    scale: cardMouse.pressed ? 0.95 : (cardMouse.containsMouse ? 1.02 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutQuad } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4

                        // Thumbnail Container (46x46)
                        Item {
                            Layout.alignment: Qt.AlignHCenter
                            width: 46
                            height: 46

                            // A. Image Thumbnail Preview
                            Rectangle {
                                anchors.fill: parent
                                radius: 9
                                color: "#1e293b"
                                clip: true
                                visible: fileCard.modelData.kind === "image"

                                Image {
                                    anchors.fill: parent
                                    source: fileCard.modelData.kind === "image" ? fileCard.modelData.url : ""
                                    fillMode: Image.PreserveAspectCrop
                                    sourceSize.width: 96
                                    sourceSize.height: 96
                                    asynchronous: true
                                }
                            }

                            // B. Folder Thumbnail (Nusa warm gold folder style)
                            Rectangle {
                                anchors.fill: parent
                                radius: 9
                                color: "#272015"
                                border.color: "#f59e0b"
                                border.width: 1
                                visible: fileCard.modelData.kind === "folder"

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 1
                                    Rectangle {
                                        width: 14
                                        height: 4
                                        radius: 2
                                        color: "#d97706"
                                    }
                                    Rectangle {
                                        width: 28
                                        height: 19
                                        radius: 3
                                        color: "#fbbf24"
                                    }
                                }
                            }

                            // C. Document / Code / Archive / Media Squircle Badge
                            Rectangle {
                                anchors.fill: parent
                                radius: 9
                                visible: fileCard.modelData.kind !== "image" && fileCard.modelData.kind !== "folder"
                                gradient: Gradient {
                                    orientation: Gradient.Vertical
                                    GradientStop {
                                        position: 0.0
                                        color: {
                                            var k = fileCard.modelData.kind;
                                            if (k === "code") return "#0284c7";
                                            if (k === "archive") return "#d97706";
                                            if (k === "audio") return "#7c3aed";
                                            if (k === "video") return "#e11d48";
                                            return "#2563eb";
                                        }
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: {
                                            var k = fileCard.modelData.kind;
                                            if (k === "code") return "#0369a1";
                                            if (k === "archive") return "#92400e";
                                            if (k === "audio") return "#4c1d95";
                                            if (k === "video") return "#9f1239";
                                            return "#1d4ed8";
                                        }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: fileCard.modelData.ext || "FILE"
                                    color: "#ffffff"
                                    font.pixelSize: 10
                                    font.weight: Font.ExtraBold
                                }
                            }
                        }

                        // File Name (Nusa .sh-name)
                        Text {
                            Layout.fillWidth: true
                            text: fileCard.modelData.name || ""
                            color: "#f8fafc"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideMiddle
                            maximumLineCount: 1
                        }

                        // File Size (Nusa .sh-size)
                        Text {
                            Layout.fillWidth: true
                            text: fileCard.modelData.size || ""
                            color: "#94a3b8"
                            font.pixelSize: 9
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    // Drag / Click Handler (Drag out to copy/move, Click to open)
                    MouseArea {
                        id: cardMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor

                        property real pressX: 0
                        property real pressY: 0
                        property bool dragStarted: false

                        onPressed: (mouse) => {
                            pressX = mouse.x
                            pressY = mouse.y
                            dragStarted = false
                        }

                        onPositionChanged: (mouse) => {
                            if (pressed && !dragStarted) {
                                var dist = Math.hypot(mouse.x - pressX, mouse.y - pressY)
                                if (dist > 6) {
                                    dragStarted = true
                                    IslandController.startShelfDrag(fileCard.index)
                                }
                            }
                        }

                        onClicked: {
                            if (!dragStarted) {
                                IslandController.openShelfFile(fileCard.index)
                            }
                        }
                    }

                    // Delete single item button (✕)
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 4
                        width: 16
                        height: 16
                        radius: 8
                        color: rmMouse.containsMouse ? "#ef4444" : "#1e293b"
                        opacity: (cardMouse.containsMouse || rmMouse.containsMouse) ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: "#ffffff"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: rmMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: IslandController.removeShelfFile(fileCard.index)
                        }
                    }
                }

                ScrollBar.horizontal: ScrollBar {
                    policy: shelfList.contentWidth > shelfList.width ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                    height: 4
                }
            }

            // 2. EMPTY / HOVER DROP OVERLAY (Nusa .sh-zone prompt)
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4
                visible: IslandController.shelfCount === 0 || root.isDragHovering

                // Animated Tray / Arrow Icon
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 34
                    height: 34
                    radius: 17
                    color: root.isDragHovering ? "#0284c7" : "#1e293b"
                    border.color: root.isDragHovering ? "#7dd3fc" : "#334155"
                    border.width: 1

                    Text {
                        id: arrowIcon
                        anchors.centerIn: parent
                        text: root.isDragHovering ? "⬇" : "📥"
                        font.pixelSize: 15
                        color: "#ffffff"
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.isDragHovering ? "Lepaskan untuk menaruh di Shelf" : "Drop files here (Seret file ke sini)"
                    color: root.isDragHovering ? "#7dd3fc" : "#f8fafc"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Seret keluar kapan saja ke aplikasi lain • Klik kartu untuk membuka"
                    color: "#64748b"
                    font.pixelSize: 10
                }
            }

            // 3. WAYLAND DROP AREA
            DropArea {
                id: shelfDropArea
                anchors.fill: parent

                onEntered: (drag) => {
                    drag.acceptProposedAction()
                    root.isDragHovering = true
                }

                onExited: {
                    root.isDragHovering = false
                }

                onDropped: (drop) => {
                    root.isDragHovering = false
                    if (drop.hasUrls) {
                        IslandController.addShelfFiles(drop.urls)
                        drop.acceptProposedAction()
                    } else if (drop.hasText) {
                        IslandController.addShelfFiles(drop.text)
                        drop.acceptProposedAction()
                    }
                }
            }
        }
    }
}
