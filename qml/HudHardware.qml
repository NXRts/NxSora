import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 250
    implicitHeight: 36

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 9

        // =====================================================================
        // 1. LEFT: HARDWARE ICON BADGE (SUN / CAPSLOCK / MICROPHONE)
        // =====================================================================
        Rectangle {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            color: {
                if (IslandController.hwHudType === "brightness") return "#33290e";
                if (IslandController.hwHudType === "capslock")
                    return IslandController.hwHudActive ? "#112f23" : "#1c1f2e";
                // mic
                return IslandController.hwHudActive ? "#112f23" : "#3b151c";
            }
            border.color: {
                if (IslandController.hwHudType === "brightness") return "#facc15";
                if (IslandController.hwHudType === "capslock")
                    return IslandController.hwHudActive ? "#22c55e" : "#475569";
                return IslandController.hwHudActive ? "#22c55e" : "#ef4444";
            }
            border.width: 1

            Image {
                anchors.centerIn: parent
                width: 13
                height: 13
                sourceSize: Qt.size(13, 13)
                source: {
                    if (IslandController.hwHudType === "brightness") return "file://" + AppConfig.assetsDir + "/sun.svg";
                    if (IslandController.hwHudType === "capslock") return "file://" + AppConfig.assetsDir + "/capslock.svg";
                    return "file://" + AppConfig.assetsDir + (IslandController.hwHudActive ? "/mic.svg" : "/mic-off.svg");
                }
            }
        }

        // =====================================================================
        // 2A. BRIGHTNESS BAR MODE (when hwHudType === "brightness")
        // =====================================================================
        Rectangle {
            visible: IslandController.hwHudType === "brightness"
            Layout.fillWidth: true
            height: 6
            radius: 3
            color: "#27272a"

            Rectangle {
                width: parent.width * (IslandController.hwHudValue / 100.0)
                height: parent.height
                radius: parent.radius
                color: "#facc15"
                Behavior on width { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }
            }
        }

        Text {
            visible: IslandController.hwHudType === "brightness"
            text: IslandController.hwHudValue + "%"
            color: "#f8fafc"
            font.pixelSize: 11
            font.weight: Font.Bold
            Layout.preferredWidth: 36
            horizontalAlignment: Text.AlignRight
        }

        // =====================================================================
        // 2B. CAPS LOCK / MICROPHONE PILL MODE (when hwHudType !== "brightness")
        // =====================================================================
        Text {
            visible: IslandController.hwHudType !== "brightness"
            Layout.fillWidth: true
            text: IslandController.hwHudLabel
            color: "#f8fafc"
            font.pixelSize: 11
            font.weight: Font.Bold
            elide: Text.ElideRight
        }

        Rectangle {
            visible: IslandController.hwHudType !== "brightness"
            height: 20
            radius: 10
            implicitWidth: stateBadgeTxt.implicitWidth + 14
            color: {
                if (IslandController.hwHudType === "capslock")
                    return IslandController.hwHudActive ? "#123826" : "#1e2230";
                return IslandController.hwHudActive ? "#123826" : "#3f151b";
            }
            border.color: {
                if (IslandController.hwHudType === "capslock")
                    return IslandController.hwHudActive ? "#22c55e" : "#475569";
                return IslandController.hwHudActive ? "#22c55e" : "#ef4444";
            }
            border.width: 1

            Text {
                id: stateBadgeTxt
                anchors.centerIn: parent
                text: {
                    if (IslandController.hwHudType === "capslock")
                        return IslandController.hwHudActive ? "AKTIF" : "NONAKTIF";
                    return IslandController.hwHudActive ? "AKTIF" : "DIBISUKAN";
                }
                color: {
                    if (IslandController.hwHudType === "capslock")
                        return IslandController.hwHudActive ? "#4ade80" : "#94a3b8";
                    return IslandController.hwHudActive ? "#4ade80" : "#f87171";
                }
                font.pixelSize: 9
                font.weight: Font.ExtraBold
            }
        }
    }
}

