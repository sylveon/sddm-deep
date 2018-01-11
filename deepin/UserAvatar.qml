import QtQuick 2.2

Canvas {
    id: avatar
    property string source: ""

    signal clicked()

    onSourceChanged: avatar.requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height)
        ctx.beginPath()
        ctx.ellipse(2.5, 2.5, width - 5, height - 5)
        ctx.clip()
        ctx.drawImage(source, 2.5, 2.5, width - 5, height - 5)
        ctx.strokeStyle = "#ffffff"
        ctx.lineWidth = 8
        ctx.stroke()
        ctx.closePath()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: avatar.clicked()
    }

    // FIXME: source value not initialized during first paint
    Timer {
        id: delayPaintTimer
        repeat: false
        interval: 10
        onTriggered: avatar.requestPaint()
        running: true
    }
}
