import QtQuick 2.2

Canvas {
    id: avatar
    property string source: ""

    signal clicked()

    onSourceChanged: delayPaintTimer.running = true
    onPaint: {
        var ctx = getContext("2d");
        ctx.beginPath()
        ctx.ellipse(2, 2, width - 4, height - 4)
        ctx.clip()
        ctx.drawImage(source, 2, 2, width - 4, height - 4)
        ctx.strokeStyle = "#ffffff"
        ctx.lineWidth = 8
        ctx.stroke()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: avatar.clicked()
    }

    // Fixme: paint() not affect event if source is not empty in initialization
    Timer {
        id: delayPaintTimer
        repeat: false
        interval: 150
        onTriggered: avatar.requestPaint()
        running: true
    }
}
