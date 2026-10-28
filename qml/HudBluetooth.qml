import QtQuick
import QtQuick.Layouts

Item {
    id: root
    implicitWidth: 310
    implicitHeight: 60

    readonly property bool isConnected: IslandController.btDeviceConnected
    readonly property int batteryPct: IslandController.btDeviceBattery
    readonly property color accentColor: isConnected ? "#5ec2ff" : "#f43f5e"

    // Choreographed Animation Properties for TWS Pop-Out (Connect) & Put-In (Disconnect)
    property real lidProgress: isConnected ? 1.0 : 0.0        // 0 = Case Lid Closed, 1 = Case Lid Open
    property real budProgress: isConnected ? 1.0 : 0.0        // 0 = Inside Case, 1 = Popped Out & Spread
    property real ringSweep: isConnected ? (batteryPct / 100.0) : 0.0
    property real rippleScale: 0.8
    property real rippleOpacity: 0.0
    property real caseBounceScale: 1.0
    property real hoverFloatY: 0.0

    onRingSweepChanged: btRingCanvas.requestPaint()
    onIsConnectedChanged: btRingCanvas.requestPaint()

    function triggerAnimation(connecting) {
        connectAnim.stop()
        disconnectAnim.stop()
        if (connecting) {
            lidProgress = 0.0
            budProgress = 0.0
            ringSweep = 0.0
            connectAnim.start()
        } else {
            lidProgress = 1.0
            budProgress = 1.0
            ringSweep = Math.max(0.15, batteryPct / 100.0)
            disconnectAnim.start()
        }
    }

    Connections {
        target: IslandController
        function onBluetoothChanged() {
            if (IslandController.state === "hud-bluetooth") {
                root.triggerAnimation(IslandController.btDeviceConnected)
            }
        }
        function onStateChanged() {
            if (IslandController.state === "hud-bluetooth") {
                root.triggerAnimation(IslandController.btDeviceConnected)
            }
        }
    }

    Component.onCompleted: {
        if (IslandController.state === "hud-bluetooth") {
            root.triggerAnimation(IslandController.btDeviceConnected)
        }
    }

    // =========================================================================
    // 1. ANIMASI PASANG TWS (Case Membuka -> Earbuds L & R Meluncur Keluar)
    // =========================================================================
    ParallelAnimation {
        id: connectAnim

        // Battery ring sweeps up smoothly
        NumberAnimation {
            target: root
            property: "ringSweep"
            from: 0.0
            to: Math.max(0.08, Math.min(1.0, root.batteryPct / 100.0))
            duration: 680
            easing.type: Easing.OutCubic
        }

        // Expanding radar wave ripple
        SequentialAnimation {
            ParallelAnimation {
                NumberAnimation { target: root; property: "rippleScale"; from: 0.75; to: 1.48; duration: 580; easing.type: Easing.OutCubic }
                NumberAnimation { target: root; property: "rippleOpacity"; from: 0.75; to: 0.0; duration: 580; easing.type: Easing.OutQuad }
            }
        }

        // Case opens -> Earbuds pop out & spread with spring overshoot
        SequentialAnimation {
            NumberAnimation {
                target: root
                property: "lidProgress"
                from: 0.0
                to: 1.0
                duration: 200
                easing.type: Easing.OutBack
            }
            ParallelAnimation {
                NumberAnimation {
                    target: root
                    property: "budProgress"
                    from: 0.0
                    to: 1.0
                    duration: 460
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.55
                }
                SequentialAnimation {
                    NumberAnimation { target: root; property: "caseBounceScale"; to: 0.93; duration: 110; easing.type: Easing.OutQuad }
                    NumberAnimation { target: root; property: "caseBounceScale"; to: 1.0; duration: 260; easing.type: Easing.OutElastic }
                }
            }
        }
    }

    // =========================================================================
    // 2. ANIMASI LEPAS TWS (Earbuds L & R Masuk ke Case -> Tutup Case Menutup)
    // =========================================================================
    ParallelAnimation {
        id: disconnectAnim

        // Battery ring sweeps down to 0
        NumberAnimation {
            target: root
            property: "ringSweep"
            to: 0.0
            duration: 540
            easing.type: Easing.InOutCubic
        }

        // Earbuds slide down into Case -> Case lid snaps shut with bounce
        SequentialAnimation {
            NumberAnimation {
                target: root
                property: "budProgress"
                from: 1.0
                to: 0.0
                duration: 340
                easing.type: Easing.InBack
                easing.overshoot: 1.1
            }
            ParallelAnimation {
                NumberAnimation {
                    target: root
                    property: "lidProgress"
                    from: 1.0
                    to: 0.0
                    duration: 210
                    easing.type: Easing.OutBounce
                }
                SequentialAnimation {
                    NumberAnimation { target: root; property: "caseBounceScale"; to: 0.90; duration: 90; easing.type: Easing.OutQuad }
                    NumberAnimation { target: root; property: "caseBounceScale"; to: 1.06; duration: 130; easing.type: Easing.OutQuad }
                    NumberAnimation { target: root; property: "caseBounceScale"; to: 1.0; duration: 160; easing.type: Easing.OutCubic }
                }
            }
        }
    }

    // Subtle floating levitation while Earbuds are popped out
    SequentialAnimation on hoverFloatY {
        running: root.isConnected && IslandController.state === "hud-bluetooth"
        loops: Animation.Infinite
        NumberAnimation { to: -1.8; duration: 950; easing.type: Easing.InOutSine }
        NumberAnimation { to: 1.5; duration: 950; easing.type: Easing.InOutSine }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 13
        anchors.rightMargin: 13
        spacing: 11

        // =====================================================================
        // 1. LEFT: ANIMATED BATTERY CONIC RING + BLUETOOTH RUNE + RADAR RIPPLE
        // =====================================================================
        Item {
            Layout.preferredWidth: 42
            Layout.preferredHeight: 42

            // Expanding Radar Ripple Ring
            Rectangle {
                anchors.centerIn: parent
                width: 38
                height: 38
                radius: 19
                color: "transparent"
                border.color: root.accentColor
                border.width: 1.8
                scale: root.rippleScale
                opacity: root.rippleOpacity
            }

            // Soft Ambient Glow
            Rectangle {
                anchors.centerIn: parent
                width: 38
                height: 38
                radius: 19
                color: root.isConnected
                       ? Qt.rgba(0.37, 0.76, 1.0, 0.15)
                       : Qt.rgba(0.96, 0.25, 0.37, 0.12)
                Behavior on color { ColorAnimation { duration: 250 } }
            }

            Canvas {
                id: btRingCanvas
                anchors.fill: parent
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var cx = width / 2;
                    var cy = height / 2;
                    var r = (Math.min(width, height) / 2) - 3;

                    // Track circle
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, Math.PI * 2);
                    ctx.lineWidth = 3.2;
                    ctx.strokeStyle = root.isConnected ? "#1b2838" : "#271c24";
                    ctx.stroke();

                    // Animated sweep arc
                    var ratio = Math.max(0.0, Math.min(1.0, root.ringSweep));
                    if (ratio > 0.01) {
                        var startAngle = -Math.PI / 2;
                        var endAngle = startAngle + (Math.PI * 2 * ratio);
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, startAngle, endAngle, false);
                        ctx.lineWidth = 3.2;
                        ctx.lineCap = "round";
                        ctx.strokeStyle = root.isConnected ? "#5ec2ff" : "#f43f5e";
                        ctx.stroke();
                    }
                }
            }

            // Center Bluetooth Rune Symbol
            Canvas {
                id: btRuneCanvas
                anchors.centerIn: parent
                width: 14
                height: 16
                antialiasing: true
                property bool connectedState: root.isConnected
                onConnectedStateChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.strokeStyle = root.isConnected ? "#5ec2ff" : "#f43f5e";
                    ctx.lineWidth = 1.6;
                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";
                    ctx.beginPath();
                    ctx.moveTo(4, 4);
                    ctx.lineTo(10, 12);
                    ctx.lineTo(7, 15);
                    ctx.lineTo(7, 1);
                    ctx.lineTo(10, 4);
                    ctx.lineTo(4, 12);
                    ctx.stroke();
                }
            }
        }

        // =====================================================================
        // 2. CENTER: DEVICE NAME + L/R EARBUD PILLS & CONNECTION STATUS
        // =====================================================================
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: IslandController.btDeviceName
                    color: "#ffffff"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                // Mini L & R Earbud Status Pill (Slides in when TWS pops out of case)
                Rectangle {
                    visible: opacity > 0.02
                    opacity: root.budProgress
                    scale: 0.85 + 0.15 * root.budProgress
                    Layout.preferredWidth: lrRow.implicitWidth + 10
                    Layout.preferredHeight: 16
                    radius: 8
                    color: "#112438"
                    border.color: "#254b73"
                    border.width: 1

                    RowLayout {
                        id: lrRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: "L"
                            color: "#5ec2ff"
                            font.pixelSize: 8
                            font.weight: Font.Black
                        }
                        Rectangle { width: 3; height: 3; radius: 1.5; color: "#33e07a" }
                        Text {
                            text: "R"
                            color: "#5ec2ff"
                            font.pixelSize: 8
                            font.weight: Font.Black
                        }
                    }
                }
            }

            RowLayout {
                spacing: 5

                Rectangle {
                    width: 6
                    height: 6
                    radius: 3
                    color: root.isConnected ? "#33e07a" : "#f43f5e"
                    Behavior on color { ColorAnimation { duration: 220 } }
                }

                Text {
                    text: root.isConnected
                          ? ("Dipasang · Baterai " + root.batteryPct + "%")
                          : "Dilepas · Masuk ke Case"
                    color: root.isConnected ? "#5ec2ff" : "#fda4af"
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                }
            }
        }

        // =====================================================================
        // 3. RIGHT: INTERACTIVE TWS CHARGING CASE + POP-OUT L/R EARBUDS
        //    (Click badge to replay / toggle Connect ↔ Disconnect animation!)
        // =====================================================================
        Rectangle {
            id: twsStageBadge
            Layout.preferredWidth: 44
            Layout.preferredHeight: 44
            radius: 22
            color: root.isConnected ? "#0f2136" : "#22131c"
            border.color: root.isConnected ? "#5ec2ff" : "#f43f5e"
            border.width: 1.5
            clip: true

            Behavior on color { ColorAnimation { duration: 250 } }
            Behavior on border.color { ColorAnimation { duration: 250 } }

            // Expanding sonic ring behind earbuds when connected
            Rectangle {
                anchors.centerIn: parent
                width: 34
                height: 34
                radius: 17
                color: "transparent"
                border.color: Qt.rgba(0.37, 0.76, 1.0, 0.35)
                border.width: 1
                scale: root.rippleScale
                opacity: root.isConnected ? root.rippleOpacity : 0.0
            }

            // -----------------------------------------------------------------
            // A. LEFT EARBUD ("L") — Pops Up & Spreads Left from Charging Case
            // -----------------------------------------------------------------
            Item {
                id: leftEarbud
                width: 12
                height: 16
                x: (parent.width / 2 - width / 2) - (3.5 + 4.8 * root.budProgress)
                y: 20 - (13.0 * root.budProgress) + (root.budProgress * root.hoverFloatY)
                rotation: -14 * root.budProgress
                opacity: 0.25 + 0.75 * Math.min(1.0, root.budProgress * 1.4)
                z: 2

                // Earbud Head (Rounded Acoustic Pod)
                Rectangle {
                    x: 2
                    y: 0
                    width: 8
                    height: 7
                    radius: 3.5
                    color: "#f8fafc"
                    border.color: "#5ec2ff"
                    border.width: 1

                    // Acoustic Grille Mesh Dot
                    Rectangle {
                        anchors.centerIn: parent
                        width: 2.5
                        height: 2.5
                        radius: 1.25
                        color: "#0f172a"
                    }
                }

                // Earbud Stem
                Rectangle {
                    x: 4
                    y: 5
                    width: 3.5
                    height: 9
                    radius: 1.7
                    color: "#e2e8f0"
                    border.color: "#94a3b8"
                    border.width: 0.5

                    // Blue Status LED on Stem
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: 2
                        height: 2
                        radius: 1
                        color: root.isConnected ? "#5ec2ff" : "#f43f5e"
                    }
                }
            }

            // -----------------------------------------------------------------
            // B. RIGHT EARBUD ("R") — Pops Up & Spreads Right from Charging Case
            // -----------------------------------------------------------------
            Item {
                id: rightEarbud
                width: 12
                height: 16
                x: (parent.width / 2 - width / 2) + (3.5 + 4.8 * root.budProgress)
                y: 20 - (13.0 * root.budProgress) - (root.budProgress * root.hoverFloatY)
                rotation: 14 * root.budProgress
                opacity: 0.25 + 0.75 * Math.min(1.0, root.budProgress * 1.4)
                z: 2

                // Earbud Head (Rounded Acoustic Pod)
                Rectangle {
                    x: 2
                    y: 0
                    width: 8
                    height: 7
                    radius: 3.5
                    color: "#f8fafc"
                    border.color: "#5ec2ff"
                    border.width: 1

                    // Acoustic Grille Mesh Dot
                    Rectangle {
                        anchors.centerIn: parent
                        width: 2.5
                        height: 2.5
                        radius: 1.25
                        color: "#0f172a"
                    }
                }

                // Earbud Stem
                Rectangle {
                    x: 4.5
                    y: 5
                    width: 3.5
                    height: 9
                    radius: 1.7
                    color: "#e2e8f0"
                    border.color: "#94a3b8"
                    border.width: 0.5

                    // Blue Status LED on Stem
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2
                        width: 2
                        height: 2
                        radius: 1
                        color: root.isConnected ? "#5ec2ff" : "#f43f5e"
                    }
                }
            }

            // -----------------------------------------------------------------
            // C. TWS CHARGING CASE (Lid Opens / Closes + Front Status LED)
            // -----------------------------------------------------------------
            Item {
                id: chargingCase
                width: 24
                height: 20
                anchors.horizontalCenter: parent.horizontalCenter
                y: 18 + (5.0 * root.budProgress)
                scale: root.caseBounceScale
                z: 3

                // Case Lid (Flips Up & Fades slightly when open; Snaps Shut when closed)
                Rectangle {
                    id: caseLid
                    width: 22
                    height: 6
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: -5 * (1.0 - root.lidProgress) - (8.0 * root.lidProgress)
                    opacity: 1.0 - (0.72 * root.lidProgress)
                    scale: 1.0 - (0.12 * root.lidProgress)
                    topLeftRadius: 5
                    topRightRadius: 5
                    bottomLeftRadius: 1
                    bottomRightRadius: 1
                    color: "#cbd5e1"
                    border.color: "#94a3b8"
                    border.width: 1
                }

                // Case Main Body
                Rectangle {
                    width: 22
                    height: 14
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 0
                    topLeftRadius: 2
                    topRightRadius: 2
                    bottomLeftRadius: 6
                    bottomRightRadius: 6
                    color: "#f1f5f9"
                    border.color: "#94a3b8"
                    border.width: 1

                    // Inner Dark Dock Cavity Slot Line
                    Rectangle {
                        width: 16
                        height: 2
                        radius: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: 1
                        color: "#1e293b"
                    }

                    // Front Charging Case LED Dot (Green when connected, Glowing Coral when charging inside case)
                    Rectangle {
                        anchors.centerIn: parent
                        width: 4
                        height: 4
                        radius: 2
                        color: root.isConnected ? "#33e07a" : "#f43f5e"

                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }
            }

            // Click on the TWS Case/Earbuds Badge to replay / toggle Connect ↔ Disconnect animation!
            MouseArea {
                anchors.fill: parent
                z: 10
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    IslandController.toggleBluetoothPeekState()
                }
            }
        }
    }
}
