import QtQuick
import Quickshell.Io

QtObject {
	id: root

	// Load user config
	property FileView configFile: FileView {
		path: "./config.json"
		JsonAdapter {
			id: configAdapter
			property string theme: "sleek"
			property string pamConfig: "password.conf"
			property int timeout: 30
			property bool showDate: true
			property bool showHint: true
			property bool clock24h: true
		}
	}

	// Resolve theme path from name. Falls back to sleek if the name is empty or unsafe.
	property string resolvedThemePath: {
		const name = configAdapter.theme;
		if (!name || name === "") return "themes/sleek/sleek.theme.json";
		const safeName = name.replace(/[^a-zA-Z0-9_-]/g, "");
		if (safeName === "") return "themes/sleek/sleek.theme.json";
		return "themes/" + safeName + "/" + safeName + ".theme.json";
	}

	// Single async theme load. Properties start with sleek defaults
	// and update when theme.json arrives. No blocking, no watching.
	property FileView themeFile: FileView {
		id: themeFile
		path: root.resolvedThemePath

		JsonAdapter {
			id: adapter

			// Base palette
			property string bg: "#000000"
			property string fg: "#ffffff"
			property string error: "#ff4444"
			property string selection: "#666666"

			// Font
			property string fontFamily: "sans-serif"

			// Type scale
			property int fontXs: 9
			property int fontBase: 13
			property int fontLg: 16
			property int fontXl: 24
			property int font3xl: 80

			// Spacing scale
			property int spaceXs: 6
			property int spaceSm: 8
			property int spaceMd: 16

			// Text colors
			property string textPrimary: "#B3FFFFFF"
			property string textStatus: "#8CFFFFFF"
			property string textSecondary: "#80FFFFFF"
			property string textMuted: "#66FFFFFF"
			property string textHint: "#59FFFFFF"
			property string textDisabled: "#4DFFFFFF"
			property string textTertiary: "#26FFFFFF"

			// Surface colors
			property string surfaceBg: "#1AFFFFFF"
			property string surfaceButton: "#14FFFFFF"
			property string surfaceDisabled: "#0DFFFFFF"
			property string spinnerStroke: "#99FFFFFF"

			// Background layers
			property string wallpaper: ""
			property real bgImageOpacity: 0.6
			property real overlayOpacity: 0.3

			// Component sizing
			property int passwordWidth: 200
			property int passwordPadding: 12
			property int passwordRadius: 6
			property int spinnerSize: 24
			property int spinnerMargin: 2
			property int spinnerStrokeWidth: 2
			property int buttonSize: 48

			// Layout positions
			property int clockTopOffset: 60
			property int marginHintBottom: 60
			property int marginCancelBottom: 40

			// Animation / timers
			property int animDuration: 600
			property int timerInterval: 1000
		}
	}

	// Behavioural settings (from config.json)
	property alias pamConfig: configAdapter.pamConfig
	property alias timeout: configAdapter.timeout
	property alias showDate: configAdapter.showDate
	property alias showHint: configAdapter.showHint
	property alias clock24h: configAdapter.clock24h

	// Visual settings (from theme.json, with sleek defaults)
	property alias bg: adapter.bg
	property alias fg: adapter.fg
	property alias error: adapter.error
	property alias selection: adapter.selection
	property alias fontFamily: adapter.fontFamily
	property alias fontXs: adapter.fontXs
	property alias fontBase: adapter.fontBase
	property alias fontLg: adapter.fontLg
	property alias fontXl: adapter.fontXl
	property alias font3xl: adapter.font3xl
	property alias spaceXs: adapter.spaceXs
	property alias spaceSm: adapter.spaceSm
	property alias spaceMd: adapter.spaceMd
	property alias textPrimary: adapter.textPrimary
	property alias textStatus: adapter.textStatus
	property alias textSecondary: adapter.textSecondary
	property alias textMuted: adapter.textMuted
	property alias textHint: adapter.textHint
	property alias textDisabled: adapter.textDisabled
	property alias textTertiary: adapter.textTertiary
	property alias surfaceBg: adapter.surfaceBg
	property alias surfaceButton: adapter.surfaceButton
	property alias surfaceDisabled: adapter.surfaceDisabled
	property alias spinnerStroke: adapter.spinnerStroke
	property alias wallpaper: adapter.wallpaper
	property alias bgImageOpacity: adapter.bgImageOpacity
	property alias overlayOpacity: adapter.overlayOpacity
	property alias passwordWidth: adapter.passwordWidth
	property alias passwordPadding: adapter.passwordPadding
	property alias passwordRadius: adapter.passwordRadius
	property alias spinnerSize: adapter.spinnerSize
	property alias spinnerMargin: adapter.spinnerMargin
	property alias spinnerStrokeWidth: adapter.spinnerStrokeWidth
	property alias buttonSize: adapter.buttonSize
	property alias clockTopOffset: adapter.clockTopOffset
	property alias marginHintBottom: adapter.marginHintBottom
	property alias marginCancelBottom: adapter.marginCancelBottom
	property alias animDuration: adapter.animDuration
	property alias timerInterval: adapter.timerInterval
}
