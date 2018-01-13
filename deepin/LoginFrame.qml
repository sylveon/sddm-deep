import QtQuick 2.0
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtGraphicalEffects 1.0
import SddmComponents 2.0

Item {
    id: frame
    property int sessionIndex: sessionModel.lastIndex
    property bool isProcessing: loadAnimation.visible
    property alias input: passwdInput
    property alias button: loginButton

    Connections {
        target: sddm
        onLoginSucceeded: {
            loadAnimation.visible = false
            Qt.quit()
        }
        onLoginFailed: {
            passwdInput.focus = false
            passwdInput.color = "red"
            passwdInputRec.color = "#55ff0000"
            wrongPasswordShake.running = true
            loadAnimation.visible = false
        }
    }

    Item {
        id: loginItem
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        UserAvatar {
            id: userIconRec
            anchors {
                top: parent.top
                topMargin: parent.height / 4 + 5
                horizontalCenter: parent.horizontalCenter
            }
            width: 130
            height: 130
            source: userFrame.currentIconPath
            onClicked: {
                if (!isProcessing)
                {
                    root.state = "stateUser"
                    userFrame.focus = true
                }
            }
        }

        ProgressBar {
            Material.accent: "white"
            visible: false
            indeterminate: true
            id: loadAnimation
            anchors.fill: passwdInputRec
        }

        Text {
            id: userNameText
            anchors {
                top: userIconRec.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }

            text: (userFrame.currentRealName === "") ? userFrame.currentUserName : userFrame.currentRealName
            color: textColor
            font.pointSize: 15
        }

        Rectangle {
            id: passwdInputRec
            visible: ! isProcessing
            anchors {
                top: userNameText.bottom
                topMargin: 10
            }
            width: 300
            height: 35
            radius: 3
            color: "#55000000"

            x: (centerArea.width - width) / 2

            TextInput {
                id: passwdInput
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8 + 36
                clip: true
                focus: true
                color: textColor
                font.pointSize: 15
                selectByMouse: true
                selectionColor: "#a8d6ec"
                echoMode: TextInput.Password
                verticalAlignment: TextInput.AlignVCenter
                onFocusChanged: {
                    if (focus) {
                        color = textColor
                        text = ""
                        parent.color = "#55000000"
                    }
                }
                onAccepted: {
                    loadAnimation.visible = true
                    sddm.login(userFrame.currentUserName, passwdInput.text, sessionIndex)
                }
                KeyNavigation.backtab: {
                    if (sessionButton.visible) {
                        return sessionButton
                    }
                    else if (userButton.visible) {
                        return userButton
                    }
                    else {
                        return shutdownButton
                    }
                }
                KeyNavigation.tab: loginButton
                Timer {
                    interval: 200
                    running: true
                    onTriggered: passwdInput.forceActiveFocus()
                }
            }
            ImgButton {
                id: loginButton
                height: passwdInput.height
                width: height
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                normalImg: "icons/login_normal.png"
                hoverImg: "icons/login_normal.png"
                pressImg: "icons/login_press.png"
                onClicked: {
                    loadAnimation.visible = true
                    sddm.login(userFrame.currentUserName, passwdInput.text, sessionIndex)
                }
                KeyNavigation.tab: shutdownButton
                KeyNavigation.backtab: passwdInput
            }

            SequentialAnimation on x {
                running: false
                id: wrongPasswordShake
                loops: 3

                NumberAnimation {
                    to: (centerArea.width - passwdInputRec.width) / 2 + 20
                    duration: 25
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    to: (centerArea.width - passwdInputRec.width) / 2 - 20
                    duration: 50
                    easing.type: Easing.InCubic
                }
                NumberAnimation {
                    to: (centerArea.width - passwdInputRec.width) / 2
                    duration: 25
                    easing.type: Easing.InCubic
                }
            }
        }
    }
}
