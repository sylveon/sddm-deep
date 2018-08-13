import QtQuick 2.3
import QtGraphicalEffects 1.0
import SddmComponents 2.0


Rectangle {
    id: root
    state: "stateLogin"

    readonly property int hMargin: 40
    readonly property int vMargin: 30
    readonly property int m_powerButtonSize: 40
    readonly property color textColor: "#ffffff"

    states: [
        State {
            name: "statePower"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 1}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 10}
        },
        State {
            name: "stateSession"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 1}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 10}
        },
        State {
            name: "stateUser"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 1}
            PropertyChanges { target: bgBlur; radius: 10}
        },
        State {
            name: "stateLogin"
            PropertyChanges { target: loginFrame; opacity: 1}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 0}
        }

    ]
    transitions: Transition {
        PropertyAnimation {
            duration: 100
            properties: "opacity"
        }
        PropertyAnimation {
            duration: 300
            properties: "radius"
        }
    }

    Item {
        id: mainFrame
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height

        Item {
            id: mainFrameBackground
            anchors.fill: parent

            Image {
                anchors.fill: parent
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                mipmap: true
                smooth: false
                source: config.background
                sourceSize.height: 3264
                sourceSize.width: 4896
            }

            Rectangle {
                anchors.fill: parent
                color: "#55000000"
            }
        }

        GaussianBlur {
            id: bgBlur
            anchors.fill: mainFrameBackground
            cached: true
            deviation: 4
            radius: 0
            samples: 20
            source: mainFrameBackground
        }

        Item {
            id: centerArea
            width: parent.width
            height: parent.height / 3
            anchors.top: parent.top
            anchors.topMargin: parent.height / 5

            PowerFrame {
                id: powerFrame
                anchors.fill: parent
                enabled: root.state == "statePower"
                onNeedClose: {
                    root.state = "stateLogin"
                    loginFrame.input.forceActiveFocus()
                }
                onNeedShutdown: sddm.powerOff()
                onNeedRestart: sddm.reboot()
                onNeedSuspend: sddm.suspend()
            }

            SessionFrame {
                id: sessionFrame
                anchors.fill: parent
                enabled: root.state == "stateSession"
                onSelected: {
                    root.state = "stateLogin"
                    loginFrame.sessionIndex = index
                    loginFrame.input.forceActiveFocus()
                }
                onNeedClose: {
                    root.state = "stateLogin"
                    loginFrame.input.forceActiveFocus()
                }
            }

            UserFrame {
                id: userFrame
                anchors.fill: parent
                enabled: root.state == "stateUser"
                onSelected: {
                    root.state = "stateLogin"
                    loginFrame.input.forceActiveFocus()
                }
                onNeedClose: {
                    root.state = "stateLogin"
                    loginFrame.input.forceActiveFocus()
                }
            }

            LoginFrame {
                id: loginFrame
                anchors.fill: parent
                enabled: root.state == "stateLogin"
                opacity: 0
                transformOrigin: Item.Top
            }
        }

        Item {
            id: timeArea
            visible: !loginFrame.isProcessing
            anchors {
                bottom: parent.bottom
                left: parent.left
            }
            width: parent.width / 3
            height: parent.height / 5

            Text {
                id: timeText
                anchors {
                    left: parent.left
                    leftMargin: hMargin
                    bottom: dateText.top
                    bottomMargin: 5
                }

                font.pointSize: 50
                color: textColor

                function updateTime() {
                    text = new Date().toLocaleTimeString(Locale.ShortFormat)
                }
            }

            Text {
                id: dateText
                anchors {
                    left: parent.left
                    leftMargin: hMargin
                    bottom: parent.bottom
                    bottomMargin: vMargin
                }

                font.pointSize: 18
                color: textColor

                function updateDate() {
                    text = new Date().toLocaleDateString()
                }
            }

            Timer {
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    timeText.updateTime()
                    dateText.updateDate()
                }
            }

            Component.onCompleted: {
                timeText.updateTime()
                dateText.updateDate()
            }
        }

        Item {
            id: powerArea
            visible: !loginFrame.isProcessing
            anchors {
                bottom: parent.bottom
                right: parent.right
            }
            width: parent.width / 3
            height: parent.height / 7

            Row {
                spacing: 20
                anchors.right: parent.right
                anchors.rightMargin: hMargin
                anchors.verticalCenter: parent.verticalCenter

                ImgButton {
                    id: sessionButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: sessionFrame.isMultipleSessions()
                    normalImg: sessionFrame.getCurrentSessionIconIndicator()
                    onClicked: {
                        root.state = "stateSession"
                        sessionFrame.focus = true
                    }
                }

                ImgButton {
                    id: userButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: userFrame.isMultipleUsers()

                    normalImg: "icons/switchframe/userswitch_normal.png"
                    hoverImg: "icons/switchframe/userswitch_hover.png"
                    pressImg: "icons/switchframe/userswitch_press.png"
                    onClicked: {
                        root.state = "stateUser"
                        userFrame.focus = true
                    }
                }

                ImgButton {
                    id: shutdownButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: sddm.canPowerOff || sddm.canReboot || sddm.canSuspend

                    normalImg: "icons/switchframe/shutdown_normal.png"
                    hoverImg: "icons/switchframe/shutdown_hover.png"
                    pressImg: "icons/switchframe/shutdown_press.png"
                    onClicked: {
                        root.state = "statePower"
                        powerFrame.focus = true
                    }
                }
            }
        }

        MouseArea {
            z: -1
            anchors.fill: parent
            onClicked: {
                root.state = "stateLogin"
                loginFrame.input.forceActiveFocus()
            }
        }
    }
}
