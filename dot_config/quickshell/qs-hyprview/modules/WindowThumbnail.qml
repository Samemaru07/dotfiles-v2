import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

Item {
    id: thumbContainer

    property var hWin: null
    property var wHandle: null
    property string winKey: ''
    property real thumbW: -1
    property real thumbH: -1
    property var clientInfo: {
    }
    property int workspaceId: 0
    property bool hovered: false
    property real targetX: -1000
    property real targetY: -1000
    property real targetZ: 0
    property real targetRotation: 0
    property bool moveCursorToActiveWindow: false

    function updateLastPos() {
        var lp = root.lastPositions || ({
        });
        var prev = lp[winKey] || ({
        });
        prev.x = x;
        prev.y = y;
        lp[winKey] = prev;
        root.lastPositions = lp;
    }

    function activateWindow() {
        if (!hWin)
            return ;

        root.toggleExpose();
        Qt.callLater(function() {
            Hyprland.dispatch("focuswindow address:0x" + hWin.address);
        });
    }

    function closeWindow() {
        if (!hWin)
            return ;

        Hyprland.dispatch("closewindow address:0x" + hWin.address);
    }

    function refreshThumb() {
        if (thumbLoader.item)
            thumbLoader.item.captureFrame();

    }

    width: thumbW
    height: thumbH
    x: 0
    y: 0
    z: targetZ
    rotation: 0
    visible: !!wHandle
    onTargetXChanged: {
        if (!root.animateWindows) {
            x = targetX;
            updateLastPos();
            return ;
        }
        var lp = root.lastPositions || ({
        });
        var prev = lp[winKey];
        var startX = (prev && prev.x !== undefined) ? prev.x : targetX;
        if (startX === targetX) {
            x = targetX;
            updateLastPos();
            return ;
        }
        animX.stop();
        animX.from = startX;
        animX.to = targetX;
        animX.start();
    }
    onTargetYChanged: {
        if (!root.animateWindows) {
            y = targetY;
            updateLastPos();
            return ;
        }
        var lp = root.lastPositions || ({
        });
        var prev = lp[winKey];
        var startY = (prev && prev.y !== undefined) ? prev.y : targetY;
        if (startY === targetY) {
            y = targetY;
            updateLastPos();
            return ;
        }
        animY.stop();
        animY.from = startY;
        animY.to = targetY;
        animY.start();
    }
    onTargetRotationChanged: {
        rotation = targetRotation;
        animRotation.stop();
        animRotation.from = 0;
        animRotation.to = targetRotation;
        animRotation.start();
    }
    onXChanged: updateLastPos()
    onYChanged: updateLastPos()
    Component.onCompleted: {
        rotation = targetRotation;
        if (!root.animateWindows) {
            x = targetX;
            y = targetY;
            updateLastPos();
        }
    }

    NumberAnimation {
        id: animX

        target: thumbContainer
        property: "x"
        duration: root.animateWindows ? 100 : 0
        easing.type: Easing.OutQuad
    }

    NumberAnimation {
        id: animY

        target: thumbContainer
        property: "y"
        duration: root.animateWindows ? 100 : 0
        easing.type: Easing.OutQuad
    }

    NumberAnimation {
        id: animRotation

        target: thumbContainer
        property: "rotation"
        duration: 400
        easing.type: Easing.OutBack // Effetto rimbalzo/inerzia
        easing.overshoot: 1.2
    }

    Item {
        id: card

        anchors.fill: parent
        scale: thumbContainer.hovered ? 1.05 : 0.95
        transformOrigin: Item.Center

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onEntered: {
                exposeArea.currentIndex = index;
            }
            onClicked: (event) => {
                exposeArea.currentIndex = index;
                if (event.button === Qt.LeftButton)
                    thumbContainer.activateWindow();

                if (event.button === Qt.MiddleButton)
                    thumbContainer.closeWindow();

            }
            onExited: {
                if (exposeArea.currentIndex === index)
                    exposeArea.currentIndex = -1;

            }
        }

        RectangularShadow {
            anchors.fill: parent
            radius: 16
            blur: 24
            spread: 10
            color: "#22000000"
            cached: true
        }

        Loader {
            id: thumbLoader

            anchors.fill: parent
            active: root.isActive && !!thumbContainer.wHandle

            sourceComponent: ScreencopyView {
                id: thumb

                anchors.fill: parent
                captureSource: thumbContainer.wHandle
                live: root.liveCapture && root.isActive
                paintCursor: false
                visible: root.isActive && thumbContainer.wHandle && hasContent
                opacity: 0.7
                layer.enabled: true

                Rectangle {
                    anchors.fill: parent
                    color: thumbContainer.hovered ? "transparent" : "#22ffffff"
                    border.width: thumbContainer.hovered ? 3 : 1
                    border.color: thumbContainer.hovered ? "#ff3174f0" : "#44ffffff"
                    radius: 16
                }

                layer.effect: OpacityMask {

                    maskSource: Rectangle {
                        width: thumb.width
                        height: thumb.height
                        radius: 24
                    }

                }

            }

        }

        Rectangle {
            id: workspaceBadge

            z: 101
            width: workspaceText.implicitWidth + 16
            height: workspaceText.implicitHeight + 8
            x: 8
            y: 8
            radius: 8
            color: workspaceId === 2 ? "#CC3174f0" : workspaceId === 3 ? "#CCa855f7" : "#CC666666"
            border.width: 1
            border.color: "#44ffffff"

            Text {
                id: workspaceText

                anchors.centerIn: parent
                text: "WS " + workspaceId
                color: "white"
                font.pixelSize: 11
                font.bold: true
            }

        }

        Rectangle {
            id: badge

            z: 100
            width: Math.min(titleText.implicitWidth + 24, thumbContainer.thumbW * 0.75)
            height: titleText.implicitHeight + 12
            x: (card.width - width) / 2
            y: card.height - height - (card.height * 0.08)
            radius: 16
            color: thumbContainer.hovered ? "#FFffffff" : "#CCffffff"
            border.width: 1
            border.color: "#44000000"

            Text {
                id: titleText

                anchors.centerIn: parent
                width: parent.width - 16
                text: hWin ? hWin.title : ""
                color: thumbContainer.hovered ? "#ff1e1e2e" : "#cc1e1e2e"
                font.pixelSize: thumbContainer.hovered ? 16 : 16
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutQuad
            }

        }

    }

}
