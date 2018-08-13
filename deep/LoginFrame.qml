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
            loginButtonOverlay.color = "#55ff0000"
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
                if (!isProcessing && userFrame.isMultipleUsers()) {
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
            color: "#99000000"

            x: (centerArea.width - width) / 2

            TextInput {
                id: passwdInput
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4 + 30
                clip: true
                focus: true
                color: textColor
                font.pointSize: 15
                selectByMouse: true
                selectionColor: "#33ffffff"
                echoMode: TextInput.Password
                verticalAlignment: TextInput.AlignVCenter
                onFocusChanged: {
                    if (focus) {
                        color = textColor
                        text = ""
                        parent.color = "#99000000"
                        loginButtonOverlay.color = "#00000000"
                    }
                }
                onAccepted: {
                    loadAnimation.visible = true
                    sddm.login(userFrame.currentUserName, passwdInput.text, sessionIndex)
                }
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
                pressImg: "icons/login_press.png"
                onClicked: {
                    loadAnimation.visible = true
                    sddm.login(userFrame.currentUserName, passwdInput.text, sessionIndex)
                }
            }

            ColorOverlay {
                id: loginButtonOverlay
                anchors.fill: loginButton
                cached: true
                source: loginButton
                color: "#00000000"
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
