import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Fusion
import Quickshell.Wayland

Rectangle {
	id: root
	required property LockContext context

	Config { id: config }

	color: config.bg

	Image {
		anchors.fill: parent
		source: config.wallpaper
		fillMode: Image.PreserveAspectCrop
		opacity: config.bgImageOpacity
	}

	Rectangle {
		anchors.fill: parent
		color: config.bg
		opacity: config.overlayOpacity
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

	Connections {
		target: root.context
		function onPamActivatedChanged() {
			if (!root.context.pamActivated) {
				root.forceActiveFocus();
			}
		}
	}

	Column {
		id: clockGroup
		anchors.horizontalCenter: parent.horizontalCenter
		y: root.context.pamActivated ? config.clockTopOffset : parent.height / 2 - height / 2
		spacing: config.spaceSm

		Behavior on y {
			NumberAnimation {
				duration: config.animDuration
				easing.type: Easing.InOutQuad
			}
		}

		Label {
			id: dateLabel
			visible: config.showDate
			property var date: new Date()

			anchors.horizontalCenter: parent.horizontalCenter

			renderType: Text.NativeRendering
			font.pointSize: config.fontXl
			font.family: config.fontFamily
			color: config.textPrimary

			Timer {
				running: true
				repeat: true
				interval: config.timerInterval

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
			font.pointSize: config.font3xl
			font.family: config.fontFamily
			color: config.textPrimary

			Timer {
				running: true
				repeat: true
				interval: config.timerInterval

				onTriggered: clock.date = new Date();
			}

			text: {
				let hours = this.date.getHours();
				const minutes = this.date.getMinutes().toString().padStart(2, '0');
				if (!config.clock24h) {
					const ampm = hours >= 12 ? 'PM' : 'AM';
					hours = hours % 12;
					hours = hours ? hours : 12;
					return `${hours.toString().padStart(2, '0')}:${minutes} ${ampm}`;
				}
				return `${hours.toString().padStart(2, '0')}:${minutes}`;
			}
		}
	}

	ColumnLayout {
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: parent.verticalCenter
		}

		spacing: config.spaceMd

		// Fingerprint indicator - shown while PAM is asking for a fingerprint
		Column {
			visible: root.context.isFingerprintPrompt
			spacing: config.spaceSm
			Layout.alignment: Qt.AlignHCenter

			Label {
				id: fingerprintIndicator
				text: "󰈷"
				color: config.fg
				font.pointSize: config.fontXl
				font.family: config.fontFamily
				anchors.horizontalCenter: parent.horizontalCenter

				SequentialAnimation {
					id: pulseAnimation
					running: fingerprintIndicator.visible
					loops: Animation.Infinite

					NumberAnimation {
						target: fingerprintIndicator
						property: "opacity"
						to: 0.4
						duration: config.animDuration * 2
					}
					NumberAnimation {
						target: fingerprintIndicator
						property: "opacity"
						to: 1.0
						duration: config.animDuration * 2
					}
				}
			}

			Label {
				text: root.context.pamMessage !== "" ? root.context.pamMessage : "Place your finger on the sensor"
				color: config.textSecondary
				font.pointSize: config.fontBase
				font.family: config.fontFamily
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

				implicitWidth: config.passwordWidth
				padding: config.passwordPadding

				focus: root.context.pamResponseRequired

				onActiveFocusChanged: {
					if (!activeFocus && visible && root.context.pamResponseRequired) {
						Qt.callLater(forceActiveFocus);
					}
				}

				enabled: !root.context.unlockInProgress
				echoMode: TextInput.Password
				inputMethodHints: Qt.ImhSensitiveData

				color: enabled ? config.textPrimary : config.textDisabled
				selectionColor: config.selection
				selectedTextColor: config.bg
				placeholderTextColor: enabled ? config.textMuted : config.textTertiary

				background: Rectangle {
					color: enabled ? config.surfaceBg : config.surfaceDisabled
					radius: config.passwordRadius
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

					function onPamActivatedChanged() {
						if (!root.context.pamActivated) {
							passwordBox.text = "";
						}
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
			implicitWidth: config.spinnerSize
			implicitHeight: config.spinnerSize
			Layout.alignment: Qt.AlignHCenter

			Rectangle {
				anchors.centerIn: parent
				width: config.spinnerSize - config.spinnerMargin * 2
				height: config.spinnerSize - config.spinnerMargin * 2
				color: "transparent"
				transform: Rotation {
					origin.x: (config.spinnerSize - config.spinnerMargin * 2) / 2
					origin.y: (config.spinnerSize - config.spinnerMargin * 2) / 2
					angle: 0

					NumberAnimation on angle {
						from: 0
						to: 360
						duration: config.animDuration * 2
						loops: Animation.Infinite
					}
				}

				Canvas {
					anchors.fill: parent
					anchors.margins: config.spinnerMargin

					onPaint: {
						var ctx = getContext("2d");
						ctx.reset();
						ctx.lineWidth = config.spinnerStrokeWidth;
						ctx.strokeStyle = config.spinnerStroke;
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
			spacing: config.spaceXs
			Layout.alignment: Qt.AlignHCenter

			Button {
				implicitWidth: config.buttonSize
				implicitHeight: config.buttonSize

				contentItem: Text {
					text: "↻"
					color: config.textSecondary
					font.pointSize: config.fontLg
					font.family: config.fontFamily
					font.weight: Font.Bold
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}

				background: Rectangle {
					color: config.surfaceButton
					radius: width / 2
				}

				onClicked: root.context.tryUnlock();
			}

			Text {
				text: "Retry"
				color: config.textHint
				font.pointSize: config.fontXs
				font.family: config.fontFamily
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
			color: root.context.pamMessageIsError ? config.error : config.textStatus
			font.pointSize: config.fontBase
			font.family: config.fontFamily
			Layout.alignment: Qt.AlignHCenter
		}
	}

	// Hint label - shown before any auth attempt
	Label {
		id: hintLabel
		visible: config.showHint && !root.context.pamActivated
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: config.marginHintBottom
		}
		text: "Click or press any key to unlock"
		color: config.textMuted
		font.pointSize: config.fontBase
		font.family: config.fontFamily

		SequentialAnimation {
			id: hintPulseAnimation
			running: hintLabel.visible
			loops: Animation.Infinite

			NumberAnimation {
				target: hintLabel
				property: "opacity"
				to: 0.5
				duration: config.animDuration * 2
			}
			NumberAnimation {
				target: hintLabel
				property: "opacity"
				to: 1.0
				duration: config.animDuration * 2
			}
		}
	}

	Column {
		visible: root.context.pamActivated
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: parent.bottom
			bottomMargin: config.marginCancelBottom
		}
		spacing: config.spaceXs

		Button {
			implicitWidth: config.buttonSize
			implicitHeight: config.buttonSize

			contentItem: Text {
				text: "✕"
				color: config.textSecondary
				font.pointSize: config.fontLg
				font.family: config.fontFamily
				font.weight: Font.Bold
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}

			background: Rectangle {
				color: config.surfaceButton
				radius: width / 2
			}

			onClicked: root.context.cancelPam();
		}

		Text {
			text: "Cancel"
			color: config.textHint
			font.pointSize: config.fontXs
			font.family: config.fontFamily
			anchors.horizontalCenter: parent.horizontalCenter
		}
	}
}
