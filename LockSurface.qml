import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland

Rectangle {
	id: root
	required property LockContext context
	required property Config config

	readonly property color bg: root.config.colors.bg
	readonly property color fg: root.config.colors.fg
	readonly property color error: root.config.colors.error

	color: bg

	Image {
		anchors.fill: parent
		source: root.config.background.image
		fillMode: Image.PreserveAspectCrop
		opacity: root.config.background.opacity
	}

	Rectangle {
		anchors.fill: parent
		color: root.config.colors.overlay
	}

	focus: true

	MouseArea {
		anchors.fill: parent
		visible: !root.context.pamActivated
		onClicked: root.context.requestUnlock()
	}

	Keys.onPressed: (event) => {
		if (!root.context.pamActivated) {
			root.context.requestUnlock();
		}
	}

	Keys.onEscapePressed: {
		if (root.context.pamActivated) {
			root.context.cancelPam();
		}
	}

	Column {
		id: clockGroup
		anchors.horizontalCenter: parent.horizontalCenter
		y: root.context.pamActivated ? 60 : parent.height / 2 - height / 2
		spacing: 8

		Behavior on y {
			enabled: root.config.animations.enabled
			NumberAnimation {
				duration: root.config.animations.clockMoveDuration
				easing.type: Easing.InOutQuad
			}
		}

		Label {
			id: dateLabel
			property var date: new Date()

			anchors.horizontalCenter: parent.horizontalCenter

			renderType: Text.NativeRendering
			font.pointSize: root.config.fonts.dateSize
			color: root.config.colors.textHigh

			Timer {
				running: true
				repeat: true
				interval: 1000

				onTriggered: dateLabel.date = new Date();
			}

			text: {
				const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
				const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
				return `${days[this.date.getDay()]}, ${months[this.date.getMonth()]} ${this.date.getDate()}, ${this.date.getFullYear()}`;
			}
		}

		Label {
			id: clock
			property var date: new Date()

			anchors.horizontalCenter: parent.horizontalCenter

			renderType: Text.NativeRendering
			font.pointSize: root.config.fonts.clockSize
			color: root.config.colors.textHigh

			Timer {
				running: true
				repeat: true
				interval: 1000

				onTriggered: clock.date = new Date();
			}

			text: {
				const hours = this.date.getHours().toString().padStart(2, '0');
				const minutes = this.date.getMinutes().toString().padStart(2, '0');
				return `${hours}:${minutes}`;
			}
		}
	}

	ColumnLayout {
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.verticalCenter
		}

		spacing: 16

		// Fingerprint indicator - shown while PAM is asking for a fingerprint
		Column {
			visible: root.context.isFingerprintPrompt
			spacing: 8
			Layout.alignment: Qt.AlignHCenter

			Label {
				id: fingerprintIndicator
				text: "󰈷"
				color: fg
				font.pointSize: root.config.fonts.fingerprintSize
				anchors.horizontalCenter: parent.horizontalCenter

				SequentialAnimation {
					id: pulseAnimation
					running: root.config.animations.enabled && fingerprintIndicator.visible
					loops: Animation.Infinite

					NumberAnimation {
						target: fingerprintIndicator
						property: "opacity"
						to: 0.4
						duration: root.config.animations.pulseDuration
					}
					NumberAnimation {
						target: fingerprintIndicator
						property: "opacity"
						to: 1.0
						duration: root.config.animations.pulseDuration
					}
				}
			}

			Label {
				text: root.context.pamMessage !== "" ? root.context.pamMessage : root.config.texts.fingerprintPrompt
				color: root.config.colors.textMid
				font.pointSize: root.config.fonts.passwordSize
				anchors.horizontalCenter: parent.horizontalCenter
			}
		}

		// Password field - shown when PAM requests a response (password fallback after fingerprint)
		RowLayout {
			visible: root.context.pamActivated && root.context.pamResponseRequired
			Layout.alignment: Qt.AlignHCenter

			TextField {
				id: passwordBox
				placeholderText: root.config.texts.passwordPlaceholder

				implicitWidth: 200
				padding: 12

				focus: true

				onActiveFocusChanged: {
					if (!activeFocus && visible) {
						Qt.callLater(forceActiveFocus);
					}
				}

				enabled: !root.context.unlockInProgress
				echoMode: TextInput.Password
				inputMethodHints: Qt.ImhSensitiveData

				font.pointSize: root.config.fonts.passwordSize

				color: enabled ? root.config.colors.textHigh : root.config.colors.textLow
				selectionColor: root.config.colors.selection
				selectedTextColor: bg
				placeholderTextColor: enabled ? root.config.colors.textMid : root.config.colors.textVeryLow

				background: Rectangle {
					color: enabled ? root.config.colors.accentBg : root.config.colors.accentBgDisabled
					radius: 6
				}

				onTextChanged: root.context.currentText = this.text;

				onAccepted: {
					if (root.context.pamResponseRequired) {
						root.context.respondToPam(passwordBox.text);
					} else {
						Qt.callLater(root.context.tryUnlock);
					}
				}

				Connections {
					target: root.context

					function onCurrentTextChanged() {
						passwordBox.text = root.context.currentText;
					}
				}

				Connections {
					target: root.context

					function onPamResponseRequiredChanged() {
						if (root.context.pamResponseRequired) {
							passwordBox.forceActiveFocus();
						}
					}
				}
			}
		}

		// Spinner loader - shown while verifying
		Item {
			visible: root.context.unlockInProgress && root.context.pamResponseRequired
			implicitWidth: 24
			implicitHeight: 24
			Layout.alignment: Qt.AlignHCenter

			Rectangle {
				anchors.centerIn: parent
				width: 20
				height: 20
				color: "transparent"
				transform: Rotation {
					origin.x: 10
					origin.y: 10
					angle: 0

					NumberAnimation on angle {
						running: root.config.animations.enabled
						from: 0
						to: 360
						duration: root.config.animations.spinnerDuration
						loops: Animation.Infinite
					}
				}

				Canvas {
					anchors.fill: parent
					anchors.margins: 2

					onPaint: {
						var ctx = getContext("2d");
						ctx.reset();
						ctx.lineWidth = 2;
						ctx.strokeStyle = root.config.colors.spinner;
						ctx.lineCap = "round";
						ctx.beginPath();
						ctx.arc(width / 2, height / 2, width / 2 - 1, 0, Math.PI * 1.5);
						ctx.stroke();
					}
				}
			}
		}

		// Retry button - shown after failed auth
		Column {
			visible: root.context.pamActivated && root.context.showFailure && !root.context.unlockInProgress
			spacing: 6
			Layout.alignment: Qt.AlignHCenter

			Button {
				implicitWidth: 48
				implicitHeight: 48

				contentItem: Text {
					text: root.config.texts.retryIcon
					color: root.config.colors.textMid
					font.pointSize: root.config.fonts.retrySize
					font.weight: Font.Bold
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}

				background: Rectangle {
					color: root.config.colors.accentBg
					radius: width / 2
				}

				onClicked: root.context.tryUnlock();
			}

			Text {
				text: root.config.texts.retryLabel
				color: root.config.colors.textLabel
				font.pointSize: 9
				anchors.horizontalCenter: parent.horizontalCenter
			}
		}

		// Status message
		Label {
			id: statusLabel
			visible: text !== ""
			text: {
				if (root.context.pamMessageIsError)
					return root.context.pamMessage;
				if (root.context.showFailure)
					return root.config.texts.authFailed;
				return "";
			}
			color: root.context.pamMessageIsError ? error : root.config.colors.textStatus
			font.pointSize: root.config.fonts.statusSize
			Layout.alignment: Qt.AlignHCenter
		}
	}

	// Hint label - shown before any auth attempt
	Label {
		id: hintLabel
		visible: !root.context.pamActivated
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: 60
		}
		text: root.config.texts.hint
		color: root.config.colors.textHint
		font.pointSize: root.config.fonts.hintSize

		SequentialAnimation {
			id: hintPulseAnimation
			running: root.config.animations.enabled && hintLabel.visible
			loops: Animation.Infinite

			NumberAnimation {
				target: hintLabel
				property: "opacity"
				to: 0.5
				duration: root.config.animations.pulseDuration
			}
			NumberAnimation {
				target: hintLabel
				property: "opacity"
				to: 1.0
				duration: root.config.animations.pulseDuration
			}
		}
	}

	Column {
		visible: root.context.pamActivated
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: 40
		}
		spacing: 6

		Button {
			implicitWidth: 48
			implicitHeight: 48

			contentItem: Text {
				text: root.config.texts.cancelIcon
				color: root.config.colors.textMid
				font.pointSize: root.config.fonts.cancelSize
				font.weight: Font.Bold
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}

			background: Rectangle {
				color: root.config.colors.accentBg
				radius: width / 2
			}

			onClicked: root.context.cancelPam();
		}

		Text {
			text: root.config.texts.cancelLabel
			color: root.config.colors.textLabel
			font.pointSize: 9
			anchors.horizontalCenter: parent.horizontalCenter
		}
	}
}
