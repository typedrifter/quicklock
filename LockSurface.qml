import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland

Rectangle {
	id: root
	required property LockContext context

	// Base palette
	readonly property color bg: "#000000"
	readonly property color fg: "#ffffff"
	readonly property color surface: "#1a1a1a"
	readonly property color border: "#333333"
	readonly property color accent: "#4a4a4a"
	readonly property color error: "#ff4444"

	// Font
	readonly property string fontFamily: "sans-serif"

	// Font sizes
	readonly property int fontDate: 24
	readonly property int fontClock: 80
	readonly property int fontFingerprintIcon: 25
	readonly property int fontFingerprintMsg: 12
	readonly property int fontRetryIcon: 16
	readonly property int fontRetryLabel: 9
	readonly property int fontStatus: 13
	readonly property int fontHint: 14
	readonly property int fontCancelIcon: 16
	readonly property int fontCancelLabel: 9

	// Text colors (white at varying opacities)
	readonly property color textPrimary: Qt.rgba(1, 1, 1, 0.7)
	readonly property color textSecondary: Qt.rgba(1, 1, 1, 0.5)
	readonly property color textMuted: Qt.rgba(1, 1, 1, 0.4)
	readonly property color textHint: Qt.rgba(1, 1, 1, 0.35)
	readonly property color textDisabled: Qt.rgba(1, 1, 1, 0.3)
	readonly property color textPlaceholder: Qt.rgba(1, 1, 1, 0.4)
	readonly property color textPlaceholderDisabled: Qt.rgba(1, 1, 1, 0.15)
	readonly property color textStatus: Qt.rgba(1, 1, 1, 0.55)

	// Surface & accent colors
	readonly property color selection: "#666666"
	readonly property color surfaceTransparent: Qt.rgba(1, 1, 1, 0.1)
	readonly property color surfaceTransparentDisabled: Qt.rgba(1, 1, 1, 0.05)
	readonly property color surfaceButton: Qt.rgba(1, 1, 1, 0.08)
	readonly property color spinnerStroke: Qt.rgba(1, 1, 1, 0.6)

	// Background overlay
	readonly property color overlayColor: "#000000"
	readonly property real bgImageOpacity: 0.6
	readonly property real overlayOpacity: 0.3

	// Layout spacing
	readonly property int spacingClock: 8
	readonly property int spacingAuth: 16
	readonly property int spacingFingerprint: 8
	readonly property int spacingRetry: 6
	readonly property int spacingCancel: 6

	// Sizing
	readonly property int passwordWidth: 200
	readonly property int passwordPadding: 12
	readonly property int passwordRadius: 6
	readonly property int spinnerSize: 24
	readonly property int spinnerInnerSize: 20
	readonly property int spinnerMargin: 2
	readonly property int spinnerStrokeWidth: 2
	readonly property int buttonSize: 48

	// Positions
	readonly property int clockTopOffset: 60
	readonly property int marginHintBottom: 60
	readonly property int marginCancelBottom: 40

	// Animation durations (ms)
	readonly property int animClockMove: 500
	readonly property int animPulse: 2000
	readonly property int animSpinner: 800

	// Timer intervals (ms)
	readonly property int timerInterval: 1000

	color: bg

	Image {
		anchors.fill: parent
		source: "background.jpg"
		fillMode: Image.PreserveAspectCrop
		opacity: bgImageOpacity
	}

	Rectangle {
		anchors.fill: parent
		color: overlayColor
		opacity: overlayOpacity
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
		y: root.context.pamActivated ? clockTopOffset : parent.height / 2 - height / 2
		spacing: spacingClock

		Behavior on y {
			NumberAnimation {
				duration: animClockMove
				easing.type: Easing.InOutQuad
			}
		}

		Label {
			id: dateLabel
			property var date: new Date()

			anchors.horizontalCenter: parent.horizontalCenter

			renderType: Text.NativeRendering
			font.pointSize: fontDate
			font.family: fontFamily
			color: textPrimary

			Timer {
				running: true
				repeat: true
				interval: timerInterval

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
			font.pointSize: fontClock
			font.family: fontFamily
			color: textPrimary

			Timer {
				running: true
				repeat: true
				interval: timerInterval

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

		spacing: spacingAuth

		// Fingerprint indicator - shown while PAM is asking for a fingerprint
		Column {
			visible: root.context.isFingerprintPrompt
			spacing: spacingFingerprint
			Layout.alignment: Qt.AlignHCenter

			Label {
				id: fingerprintIndicator
				text: "󰈷"
				color: fg
				font.pointSize: fontFingerprintIcon
				font.family: fontFamily
				anchors.horizontalCenter: parent.horizontalCenter

				SequentialAnimation {
					id: pulseAnimation
					running: fingerprintIndicator.visible
					loops: Animation.Infinite

					NumberAnimation {
						target: fingerprintIndicator
						property: "opacity"
						to: 0.4
						duration: animPulse
					}
					NumberAnimation {
						target: fingerprintIndicator
						property: "opacity"
						to: 1.0
						duration: animPulse
					}
				}
			}

			Label {
				text: root.context.pamMessage !== "" ? root.context.pamMessage : "Place your finger on the sensor"
				color: textSecondary
				font.pointSize: fontFingerprintMsg
				font.family: fontFamily
				anchors.horizontalCenter: parent.horizontalCenter
			}
		}

		// Password field - shown when PAM requests a response (password fallback after fingerprint)
		RowLayout {
			visible: root.context.pamActivated && root.context.pamResponseRequired
			Layout.alignment: Qt.AlignHCenter

			TextField {
				id: passwordBox
				placeholderText: "Enter password"

				implicitWidth: passwordWidth
				padding: passwordPadding

				focus: true

				onActiveFocusChanged: {
					if (!activeFocus && visible) {
						Qt.callLater(forceActiveFocus);
					}
				}

				enabled: !root.context.unlockInProgress
				echoMode: TextInput.Password
				inputMethodHints: Qt.ImhSensitiveData

				color: enabled ? textPrimary : textDisabled
				selectionColor: selection
				selectedTextColor: bg
				placeholderTextColor: enabled ? textPlaceholder : textPlaceholderDisabled

				background: Rectangle {
					color: enabled ? surfaceTransparent : surfaceTransparentDisabled
					radius: passwordRadius
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

			// Button {
			// 	id: unlockButton
			// 	implicitWidth: passwordBox.implicitHeight * .8
			// 	implicitHeight: passwordBox.implicitHeight * .8
			//
			// 	focusPolicy: Qt.NoFocus
			//
			// 	enabled: !root.context.unlockInProgress && root.context.currentText !== "";
			//
			// 	contentItem: Text {
			// 		text: "›"
			// 		color: parent.enabled ? textPrimary : textDisabled
			// 		font.pointSize: 28
			// 		font.family: fontFamily
			// 		horizontalAlignment: Text.AlignHCenter
			// 		verticalAlignment: Text.AlignVCenter
			// 	}
			//
			// 	background: Rectangle {
			// 		color: parent.enabled ? surfaceTransparent : surfaceTransparentDisabled
			// 		radius: width / 2
			// 	}
			//
			// 	onClicked: {
			// 		if (root.context.pamResponseRequired) {
			// 			root.context.respondToPam(passwordBox.text);
			// 		} else {
			// 			Qt.callLater(root.context.tryUnlock);
			// 		}
			// 	}
			// }
		}

		// Spinner loader - shown while verifying
		Item {
			visible: root.context.unlockInProgress && root.context.pamResponseRequired
			implicitWidth: spinnerSize
			implicitHeight: spinnerSize
			Layout.alignment: Qt.AlignHCenter

			Rectangle {
				anchors.centerIn: parent
				width: spinnerInnerSize
				height: spinnerInnerSize
				color: "transparent"
				transform: Rotation {
					origin.x: spinnerInnerSize / 2
					origin.y: spinnerInnerSize / 2
					angle: 0

					NumberAnimation on angle {
						from: 0
						to: 360
						duration: animSpinner
						loops: Animation.Infinite
					}
				}

				Canvas {
					anchors.fill: parent
					anchors.margins: spinnerMargin

					onPaint: {
						var ctx = getContext("2d");
						ctx.reset();
						ctx.lineWidth = spinnerStrokeWidth;
						ctx.strokeStyle = spinnerStroke;
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
			spacing: spacingRetry
			Layout.alignment: Qt.AlignHCenter

			Button {
				implicitWidth: buttonSize
				implicitHeight: buttonSize

				contentItem: Text {
					text: "↻"
					color: textSecondary
					font.pointSize: fontRetryIcon
					font.family: fontFamily
					font.weight: Font.Bold
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}

				background: Rectangle {
					color: surfaceButton
					radius: width / 2
				}

				onClicked: root.context.tryUnlock();
			}

			Text {
				text: "Retry"
				color: textHint
				font.pointSize: fontRetryLabel
				font.family: fontFamily
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
					return "Authentication failed";
				return "";
			}
			color: root.context.pamMessageIsError ? error : textStatus
			font.pointSize: fontStatus
			font.family: fontFamily
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
			bottomMargin: marginHintBottom
		}
		text: "Click or press any key to unlock"
		color: textMuted
		font.pointSize: fontHint
		font.family: fontFamily

		SequentialAnimation {
			id: hintPulseAnimation
			running: hintLabel.visible
			loops: Animation.Infinite

			NumberAnimation {
				target: hintLabel
				property: "opacity"
				to: 0.5
				duration: animPulse
			}
			NumberAnimation {
				target: hintLabel
				property: "opacity"
				to: 1.0
				duration: animPulse
			}
		}
	}

	Column {
		visible: root.context.pamActivated
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: marginCancelBottom
		}
		spacing: spacingCancel

		Button {
			implicitWidth: buttonSize
			implicitHeight: buttonSize

			contentItem: Text {
				text: "✕"
				color: textSecondary
				font.pointSize: fontCancelIcon
				font.family: fontFamily
				font.weight: Font.Bold
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}

			background: Rectangle {
				color: surfaceButton
				radius: width / 2
			}

			onClicked: root.context.cancelPam();
		}

		Text {
			text: "Cancel"
			color: textHint
			font.pointSize: fontCancelLabel
			font.family: fontFamily
			anchors.horizontalCenter: parent.horizontalCenter
		}
	}
}
