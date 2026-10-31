import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        // =====================================================================
        // ROW 1: SEARCH BAR & STATS & CLEAR BUTTON (HEIGHT: 28px)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            Layout.maximumHeight: 28
            spacing: 6

            // Search Input Container
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: "#12131c"
                border.color: searchInput.activeFocus ? "#38bdf8" : "#24273a"
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    Image {
                        width: 12
                        height: 12
                        sourceSize: Qt.size(12, 12)
                        source: "file://" + AppConfig.assetsDir + "/clipboard.svg"
                        opacity: 0.6
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: "#ffffff"
                        font.pixelSize: 11
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: "Cari riwayat salinan..."
                            color: "#64748b"
                            font.pixelSize: 11
                            visible: !searchInput.text && !searchInput.activeFocus
                        }

                        onTextChanged: {
                            IslandController.setClipboardSearch(text);
                        }
                    }

                    // Clear search button if active
                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        color: "#334155"
                        visible: searchInput.text.length > 0
                        Image {
                            anchors.centerIn: parent
                            width: 8
                            height: 8
                            sourceSize: Qt.size(8, 8)
                            source: "file://" + AppConfig.assetsDir + "/close.svg"
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchInput.text = "";
                                IslandController.setClipboardSearch("");
                            }
                        }
                    }
                }
            }

            // Stats Pill
            Rectangle {
                Layout.preferredHeight: 28
                radius: 8
                color: "#12131c"
                border.color: "#24273a"
                border.width: 1
                implicitWidth: statsText.implicitWidth + 14

                Text {
                    id: statsText
                    anchors.centerIn: parent
                    text: IslandController.clipboardCount + " Klip" + (IslandController.clipboardPinnedCount > 0 ? (" • " + IslandController.clipboardPinnedCount + " Pin") : "")
                    color: "#94a3b8"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }

            // Clear Unpinned Button
            Rectangle {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 8
                color: clearMouse.containsMouse ? "#7f1d1d" : "#12131c"
                border.color: clearMouse.containsMouse ? "#ef4444" : "#24273a"
                border.width: 1

                Image {
                    anchors.centerIn: parent
                    width: 12
                    height: 12
                    sourceSize: Qt.size(12, 12)
                    source: "file://" + AppConfig.assetsDir + "/trash.svg"
                    opacity: clearMouse.containsMouse ? 1.0 : 0.7
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.clearClipboardUnpinned()
                }
            }
        }

        // =====================================================================
        // ROW 2: CLIPBOARD ITEMS LISTVIEW (SCROLLABLE)
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: "#12131c"
            border.color: "#24273a"
            border.width: 1
            clip: true

            ListView {
                id: clipList
                anchors.fill: parent
                anchors.margins: 4
                spacing: 3
                model: IslandController.clipboardHistory

                delegate: Rectangle {
                    id: itemBox
                    width: clipList.width
                    height: 38
                    radius: 7
                    color: itemMouse.containsMouse ? "#1e2438" : (modelData.pinned ? "#1a2133" : "#151722")
                    border.color: modelData.pinned ? "#38bdf8" : (itemMouse.containsMouse ? "#334155" : "#1e2233")
                    border.width: modelData.pinned ? 1 : 0.5

                    property bool copiedAnim: false

                    Timer {
                        id: copiedTimer
                        interval: 1200
                        onTriggered: itemBox.copiedAnim = false
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        // Type Badge
                        Rectangle {
                            width: 22
                            height: 22
                            radius: 6
                            color: modelData.type === "link" ? "#075985" :
                                   (modelData.type === "code" ? "#4c1d95" :
                                   (modelData.type === "color" ? "#065f46" : "#1e293b"))

                            Image {
                                anchors.centerIn: parent
                                width: 11
                                height: 11
                                sourceSize: Qt.size(11, 11)
                                source: "file://" + AppConfig.assetsDir + "/" + (
                                    modelData.type === "link" ? "globe.svg" :
                                    (modelData.type === "code" ? "terminal.svg" :
                                    (modelData.type === "color" ? "pipette.svg" : "clipboard.svg"))
                                )
                            }
                        }

                        // Text Preview & Timestamp
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: itemBox.copiedAnim ? "Tersalin ke Clipboard!" : modelData.preview
                                color: itemBox.copiedAnim ? "#4ade80" : "#f1f5f9"
                                font.pixelSize: 11
                                font.weight: itemBox.copiedAnim ? Font.Bold : Font.Normal
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            RowLayout {
                                spacing: 4
                                Text {
                                    text: modelData.timestamp
                                    color: "#64748b"
                                    font.pixelSize: 9
                                }
                                Text {
                                    text: "• " + modelData.length + " karakter"
                                    color: "#475569"
                                    font.pixelSize: 9
                                }
                            }
                        }

                        // Action Buttons: [Copy] [Pin] [Delete]
                        RowLayout {
                            spacing: 3

                            // Copy Button
                            Rectangle {
                                width: 24
                                height: 24
                                radius: 6
                                color: copyBtnMouse.containsMouse ? "#0284c7" : "#1e293b"
                                border.color: "#334155"
                                border.width: 1

                                Image {
                                    anchors.centerIn: parent
                                    width: 11
                                    height: 11
                                    sourceSize: Qt.size(11, 11)
                                    source: "file://" + AppConfig.assetsDir + "/" + (itemBox.copiedAnim ? "check.svg" : "clipboard.svg")
                                }

                                MouseArea {
                                    id: copyBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        IslandController.copyClipboardItem(modelData.id);
                                        itemBox.copiedAnim = true;
                                        copiedTimer.restart();
                                    }
                                }
                            }

                            // Pin Button
                            Rectangle {
                                width: 24
                                height: 24
                                radius: 6
                                color: modelData.pinned ? "#0369a1" : (pinBtnMouse.containsMouse ? "#334155" : "#1e293b")
                                border.color: modelData.pinned ? "#38bdf8" : "#334155"
                                border.width: 1

                                Image {
                                    anchors.centerIn: parent
                                    width: 11
                                    height: 11
                                    sourceSize: Qt.size(11, 11)
                                    source: "file://" + AppConfig.assetsDir + "/pin.svg"
                                    opacity: modelData.pinned ? 1.0 : 0.6
                                }

                                MouseArea {
                                    id: pinBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: IslandController.toggleClipboardPin(modelData.id)
                                }
                            }

                            // Delete Button
                            Rectangle {
                                width: 24
                                height: 24
                                radius: 6
                                color: delBtnMouse.containsMouse ? "#7f1d1d" : "#1e293b"
                                border.color: delBtnMouse.containsMouse ? "#ef4444" : "#334155"
                                border.width: 1

                                Image {
                                    anchors.centerIn: parent
                                    width: 10
                                    height: 10
                                    sourceSize: Qt.size(10, 10)
                                    source: "file://" + AppConfig.assetsDir + "/close.svg"
                                    opacity: delBtnMouse.containsMouse ? 1.0 : 0.6
                                }

                                MouseArea {
                                    id: delBtnMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: IslandController.deleteClipboardItem(modelData.id)
                                }
                            }
                        }
                    }

                    // Click whole row to copy
                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            IslandController.copyClipboardItem(modelData.id);
                            itemBox.copiedAnim = true;
                            copiedTimer.restart();
                        }
                    }
                }

                // Empty State
                Item {
                    anchors.centerIn: parent
                    visible: clipList.count === 0
                    width: 200
                    height: 80

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Image {
                            Layout.alignment: Qt.AlignHCenter
                            width: 24
                            height: 24
                            sourceSize: Qt.size(24, 24)
                            source: "file://" + AppConfig.assetsDir + "/clipboard.svg"
                            opacity: 0.35
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Belum ada riwayat clipboard"
                            color: "#64748b"
                            font.pixelSize: 11
                        }
                    }
                }
            }
        }
    }
}

