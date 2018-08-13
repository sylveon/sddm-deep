import QtQuick 2.2
import QtGraphicalEffects 1.0

Item {
    id: avatar
    property alias source: img.source

    signal clicked()

    Image {
        id: img
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        layer {
            enabled: true
            effect: OpacityMask {
                maskSource: avatarMask
            }
        }
    }

    Rectangle {
        id: avatarMask
        anchors.fill: parent
        radius: width / 2
        visible: false
    }

    Rectangle {
        id: avatarBorder
        anchors.fill: parent
        radius: width / 2

        border {
            width: 6
            color: "white"
        }
        color: "transparent"
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            if (!frame.isProcessing)
                avatarBorder.border.color = "#77ffffff"
        }
        onExited: {
            avatarBorder.border.color = "white"
        }
        onClicked: avatar.clicked()
    }
}
