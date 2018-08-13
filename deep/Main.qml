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

    function returnToLogin() {
        root.state = "stateLogin"
        loginFrame.input.forceActiveFocus()
    }

    states: [
        State {
            name: "statePower"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 1}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 7.5}
        },
        State {
            name: "stateSession"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 1}
            PropertyChanges { target: userFrame; opacity: 0}
            PropertyChanges { target: bgBlur; radius: 7.5}
        },
        State {
            name: "stateUser"
            PropertyChanges { target: loginFrame; opacity: 0}
            PropertyChanges { target: powerFrame; opacity: 0}
            PropertyChanges { target: sessionFrame; opacity: 0}
            PropertyChanges { target: userFrame; opacity: 1}
            PropertyChanges { target: bgBlur; radius: 7.5}
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

        RecursiveBlur {
            id: bgBlur
            anchors.fill: mainFrameBackground
            cached: true
            loops: 20
            radius: 0
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
                onNeedClose: returnToLogin()
                onNeedShutdown: sddm.powerOff()
                onNeedRestart: sddm.reboot()
                onNeedSuspend: sddm.suspend()
            }

            SessionFrame {
                id: sessionFrame
                anchors.fill: parent
                enabled: root.state == "stateSession"
                onSelected: {
                    loginFrame.sessionIndex = index
                    returnToLogin()
                }
                onNeedClose: returnToLogin()
            }

            UserFrame {
                id: userFrame
                anchors.fill: parent
                enabled: root.state == "stateUser"
                onSelected: returnToLogin()
                onNeedClose: returnToLogin()
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

                function frameButtonClick(frame, state) {
                    if (root.state != state)
                    {
                        root.state = state
                        frame.focus = true
                    }
                    else
                    {
                        frame.needClose()
                    }
                }

                ImgButton {
                    id: sessionButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: sessionFrame.isMultipleSessions()
                    normalImg: sessionFrame.getCurrentSessionIconIndicator()
                    onClicked: parent.frameButtonClick(sessionFrame, "stateSession")
                }

                ImgButton {
                    id: userButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: userFrame.isMultipleUsers()

                    normalImg: "icons/switchframe/userswitch_normal.png"
                    hoverImg: "icons/switchframe/userswitch_hover.png"
                    pressImg: "icons/switchframe/userswitch_press.png"
                    onClicked: parent.frameButtonClick(userFrame, "stateUser")
                }

                ImgButton {
                    id: shutdownButton
                    width: m_powerButtonSize
                    height: m_powerButtonSize
                    visible: sddm.canPowerOff || sddm.canReboot || sddm.canSuspend

                    normalImg: "icons/switchframe/shutdown_normal.png"
                    hoverImg: "icons/switchframe/shutdown_hover.png"
                    pressImg: "icons/switchframe/shutdown_press.png"
                    onClicked: parent.frameButtonClick(powerFrame, "statePower")
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
