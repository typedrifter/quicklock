import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
	id: root
	signal unlocked()
	signal failed()

	Config { id: appConfig }

	property string currentText: ""
	property bool unlockInProgress: false
	property bool showFailure: false
	property bool pamActivated: false
	property bool timedOut: false

	// Expose PAM state for the UI
	readonly property alias pamMessage: pam.message
	readonly property alias pamMessageIsError: pam.messageIsError
	readonly property alias pamResponseRequired: pam.responseRequired
	readonly property alias pamResponseVisible: pam.responseVisible
	readonly property bool isFingerprintPrompt: pam.message.toLowerCase().includes("fingerprint")

	onCurrentTextChanged: {
		showFailure = false;
		if (pamActivated) timeoutTimer.restart();
	}

	function requestUnlock() {
		if (root.unlockInProgress) return;
		if (root.pamActivated) return;
		root.pamActivated = true;
		root.timedOut = false;
		root.showFailure = false;
		timeoutTimer.restart();
		tryUnlock();
	}

	function tryUnlock() {
		if (root.unlockInProgress) return;
		root.unlockInProgress = true;
		root.showFailure = false;
		pam.start();
	}

	function cancelPam() {
		timeoutTimer.stop();
		root.timedOut = true;
		if (pam.active) {
			pam.abort();
		}
		root.pamActivated = false;
		root.unlockInProgress = false;
		root.showFailure = false;
		root.currentText = "";
	}

	function respondToPam(response) {
		if (pam.responseRequired) {
			root.unlockInProgress = true;
			timeoutTimer.restart();
			pam.respond(response);
		}
	}

	Timer {
		id: timeoutTimer
		interval: appConfig.timeout * 1000
		repeat: false
		onTriggered: cancelPam()
	}

	PamContext {
		id: pam

		// Support both relative (to pam/) and absolute paths for the PAM config.
		property string rawConfig: appConfig.pamConfig || "password.conf"
		property bool rawIsAbsolute: rawConfig.charAt(0) === '/'
		property int rawLastSlash: rawIsAbsolute ? rawConfig.lastIndexOf('/') : -1

		configDirectory: rawIsAbsolute ? rawConfig.substring(0, rawLastSlash) : "pam"
		config: rawIsAbsolute ? rawConfig.substring(rawLastSlash + 1) : rawConfig

		onPamMessage: {
			if (this.responseRequired) {
				root.unlockInProgress = false;
				timeoutTimer.restart();
			}
		}

		onCompleted: result => {
			if (root.timedOut) return;
			if (result == PamResult.Success) {
				root.unlocked();
			} else {
				root.currentText = "";
				root.showFailure = true;
			}

			root.unlockInProgress = false;
		}

		onError: error => {
			if (root.timedOut) return;
			root.unlockInProgress = false;
		}
	}
}
