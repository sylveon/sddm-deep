import QtQuick 2.0

Rectangle {
    color: "transparent"
    width: 30
    height: 30
    property url normalImg: ""
    property url hoverImg: normalImg
    property url pressImg: normalImg

    signal clicked()

    onNormalImgChanged: img.source = normalImg

    Image {
        id: img
        source: normalImg
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: img.source = hoverImg
        onPressed: img.source = pressImg
        onExited: img.source = normalImg
        onReleased: img.source = normalImg
        onClicked: parent.clicked()
    }
}
