import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 8

        // =====================================================================
        // HEADER: TITLE + PROGRESS BADGE + CLEAR COMPLETED
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                width: 24
                height: 24
                radius: 6
                color: "#16a34a"
                Text {
                    anchors.centerIn: parent
                    text: "✓"
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                }
            }

            Text {
                text: "Daftar Tugas Harian"
                color: "#f8fafc"
                font.pixelSize: 12
                font.weight: Font.Bold
            }

            Rectangle {
                width: 55
                height: 20
                radius: 10
                color: "#14532d"
                Text {
                    anchors.centerIn: parent
                    text: IslandController.tasksSummaryText + " Selesai"
                    color: "#86efac"
                    font.pixelSize: 9
                    font.weight: Font.Bold
                }
            }

            Item { Layout.fillWidth: true }

            // Clear Completed Button
            Rectangle {
                width: 82
                height: 22
                radius: 11
                color: clearMouse.containsMouse ? "#334155" : "#1e293b"
                border.color: "#334155"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Bersihkan Selesai"
                    color: "#94a3b8"
                    font.pixelSize: 9
                    font.weight: Font.Medium
                }

                MouseArea {
                    id: clearMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: IslandController.clearCompletedTasks()
                }
            }
        }

        // =====================================================================
        // INPUT BAR: TAMBAH TUGAS BARU
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            height: 32
            radius: 8
            color: "#161824"
            border.color: inputField.activeFocus ? "#38bdf8" : "#282b3d"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 6
                spacing: 6

                TextInput {
                    id: inputField
                    Layout.fillWidth: true
                    color: "#f8fafc"
                    font.pixelSize: 11
                    selectByMouse: true
                    clip: true

                    Text {
                        anchors.fill: parent
                        text: "Ketik tugas baru lalu tekan Enter..."
                        color: "#64748b"
                        font.pixelSize: 11
                        visible: !inputField.text && !inputField.activeFocus
                    }

                    onAccepted: {
                        if (text.trim() !== "") {
                            IslandController.addTask(text.trim())
                            text = ""
                        }
                    }
                }

                Rectangle {
                    width: 50
                    height: 22
                    radius: 6
                    color: addMouse.containsMouse ? "#2563eb" : "#1d4ed8"

                    Text {
                        anchors.centerIn: parent
                        text: "+ Tambah"
                        color: "#ffffff"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }

                    MouseArea {
                        id: addMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (inputField.text.trim() !== "") {
                                IslandController.addTask(inputField.text.trim())
                                inputField.text = ""
                            }
                        }
                    }
                }
            }
        }

        // =====================================================================
        // LIST VIEW OF TASKS
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 10
            color: "#121420"
            border.color: "#1e2235"
            border.width: 1
            clip: true

            ListView {
                id: taskList
                anchors.fill: parent
                anchors.margins: 6
                spacing: 5
                model: IslandController.tasks

                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: taskList.width
                    height: 28
                    radius: 6
                    color: taskMouse.containsMouse ? "#1c1f30" : "#161826"
                    border.color: modelData.done ? "#166534" : "#26293d"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 6
                        spacing: 8

                        // Checkbox circle
                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            color: modelData.done ? "#22c55e" : "transparent"
                            border.color: modelData.done ? "#22c55e" : "#64748b"
                            border.width: 1.5

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                color: "#ffffff"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                visible: modelData.done
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: IslandController.toggleTask(index)
                            }
                        }

                        // Task text
                        Text {
                            Layout.fillWidth: true
                            text: modelData.text || ""
                            color: modelData.done ? "#64748b" : "#f1f5f9"
                            font.pixelSize: 11
                            font.strikeout: modelData.done
                            elide: Text.ElideRight
                        }

                        // Delete button (✕)
                        Text {
                            text: "✕"
                            color: delMouse.containsMouse ? "#ef4444" : "#64748b"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            padding: 4

                            MouseArea {
                                id: delMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: IslandController.removeTask(index)
                            }
                        }
                    }

                    MouseArea {
                        id: taskMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        z: -1
                        onClicked: IslandController.toggleTask(index)
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: taskList.contentHeight > taskList.height ? ScrollBar.AlwaysOn : ScrollBar.AsNeeded
                    width: 4
                }
            }
        }
    }
}
