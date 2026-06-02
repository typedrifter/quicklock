import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import QtMultimedia

Rectangle {
    id: root
    required property LockContext context

    property bool showUnlock: false

    // video background
    Video {
        id: video
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
        loops: MediaPlayer.Infinite
        source: Qt.resolvedUrl("video.mp4")
        autoPlay: true
    }

    // Listen to keys and mouse click
    // manage the main show/hide unlock logic
    Rectangle {
        id: mainListener
        anchors.fill: parent
        color: "#000000"
        opacity: 0
        focus: true

        Keys.onPressed: event => {
            if (root.showUnlock)
                return;
            root.showUnlock = true;
        }

        MouseArea {
            cursorShape: Qt.BlankCursor
            anchors.fill: parent
            onClicked: {
                if (root.showUnlock)
                    return;
                root.showUnlock = true;
            }
        }

        // hide unlock input after 10 seconds of idle
        IdleMonitor {
            id: idle
            timeout: 10
            onIsIdleChanged: {
                if (isIdle) {
                    root.showUnlock = false;
                    mainListener.focus = true;
                }
            }
        }
    }

    ColumnLayout {
        id: dateTime
        anchors {
            horizontalCenter: parent.horizontalCenter
        }
        property var date: new Date()

        y: root.showUnlock ? parent.height / 4 : parent.height / 2 - height / 2

        Behavior on y {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        // updates the clock every second
        Timer {
            running: true
            repeat: true
            interval: 1000

            onTriggered: parent.date = new Date()
        }

        Label {
            id: date
            Layout.alignment: Qt.AlignHCenter

            renderType: Text.NativeRendering
            font.pointSize: 30

            // updated when the date changes
            text: {
                Qt.formatDate(dateTime.date, "dddd d MMMM");
            }
        }

        Label {
            id: clock
            Layout.alignment: Qt.AlignHCenter

            renderType: Text.NativeRendering
            font.pointSize: 80

            // updated when the date changes
            text: {
                const hours = dateTime.date.getHours().toString().padStart(2, '0');
                const minutes = dateTime.date.getMinutes().toString().padStart(2, '0');
                return `${hours}:${minutes}`;
            }
        }
    }

    ColumnLayout {
        id: unlockColumn

        opacity: root.showUnlock ? 1 : 0
        visible: opacity != 0

        Behavior on opacity {
            NumberAnimation {
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }

        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        TextField {
            id: passwordInput
            focus: unlockColumn.visible
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData
            placeholderText: "Enter password"

            // Update the text in the context when the text in the box changes.
            onTextChanged: root.context.currentText = this.text

            // Try to unlock when enter is pressed.
            onAccepted: root.context.tryUnlock()

            implicitWidth: 200
            padding: 10

            background: Rectangle {
                color: Qt.rgba(0, 0, 0, 0.25)
                radius: 6
            }

            Layout.alignment: Qt.AlignHCenter
            renderType: Text.NativeRendering
            font.pointSize: 14
            // horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: ""
            cursorVisible: false

            // reset if esc is pressed
            Keys.onPressed: event => {
                if (event.key == Qt.Key_Escape) {
                    root.showUnlock = !root.showUnlock;
                    // set focus back to the main listener
                    mainListener.focus = true;
                }
            }

            // reset if input is hidden
            onVisibleChanged: {
                if (!visible) {
                    text = "";
                }
            }
        }
    }

    Label {
        id: cancelLabel

        text: "press esc to cancel"

        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter

        font.pointSize: 12

        opacity: root.showUnlock ? .2 : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }

        SequentialAnimation {
            running: root.showUnlock
            loops: Animation.Infinite

            NumberAnimation {
                target: cancelLabel
                property: "opacity"
                from: 0.2
                to: 0.75
                duration: 1000
            }

            NumberAnimation {
                target: cancelLabel
                property: "opacity"
                from: 0.75
                to: 0.2
                duration: 1000
            }
        }
    }
}
