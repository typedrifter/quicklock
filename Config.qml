import QtQuick
import Quickshell
import Quickshell.Io

Scope {
	id: root

	property var _overrides: ({})

	function _merge(base, patch) {
		if (!patch || typeof patch !== "object") return base;
		const out = {};
		for (const k in base) out[k] = patch.hasOwnProperty(k) ? patch[k] : base[k];
		return out;
	}

	property var colors: _merge({
		bg: "#000000",
		fg: "#ffffff",
		error: "#ff4444",
		overlay: "#4d000000",
		textHigh: "#b3ffffff",
		textMid: "#80ffffff",
		textLow: "#4dffffff",
		textVeryLow: "#26ffffff",
		accentBg: "#1affffff",
		accentBgDisabled: "#0dffffff",
		selection: "#666666",
		spinner: "#99ffffff",
		textStatus: "#8cffffff",
		textHint: "#66ffffff",
		textLabel: "#59ffffff"
	}, _overrides.colors)

	property var background: _merge({
		image: "background.jpg",
		opacity: 0.6
	}, _overrides.background)

	property var fonts: _merge({
		dateSize: 24,
		clockSize: 80,
		fingerprintSize: 25,
		statusSize: 13,
		hintSize: 14,
		passwordSize: 12,
		retrySize: 16,
		cancelSize: 16
	}, _overrides.fonts)

	property var texts: _merge({
		fingerprintPrompt: "Place your finger on the sensor",
		passwordPlaceholder: "Enter password",
		retryLabel: "Retry",
		retryIcon: "↻",
		cancelLabel: "Cancel",
		cancelIcon: "✕",
		hint: "Click or press any key to unlock",
		authFailed: "Authentication failed"
	}, _overrides.texts)

	property var pam: _merge({
		configDirectory: "pam",
		config: "password.conf",
		timeout: 30000
	}, _overrides.pam)

	property var animations: _merge({
		enabled: true,
		clockMoveDuration: 500,
		pulseDuration: 2000,
		spinnerDuration: 800
	}, _overrides.animations)

	FileView {
		path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/quicklock/config.json"
		onLoaded: {
			try {
				root._overrides = JSON.parse(text());
			} catch (e) {
				console.warn("quicklock: bad config.json:", e);
			}
		}
		onLoadFailed: {} // silently use defaults
	}
}
