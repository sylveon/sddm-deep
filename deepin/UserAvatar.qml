import QtQuick 2.2
import QtGraphicalEffects 1.0

Item {
    id: avatar
    property string source: ""

    signal clicked()

    Image {
        id: img
        anchors.fill: parent
        source: parent.source

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Item {
                width: img.width
                height: img.height
                Rectangle {
                    anchors.fill: parent
                    radius: width
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: width

        border {
            width: 6
            color: "white"
        }
        color: "transparent"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: avatar.clicked()
    }
}
