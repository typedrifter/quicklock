import QtQuick

QtObject {
	// Base palette
	readonly property color bg: "#000000"
	readonly property color fg: "#ffffff"
	readonly property color error: "#ff4444"
	readonly property color selection: "#666666"

	// Font
	readonly property string fontFamily: "sans-serif"

	// Type scale
	readonly property int fontXs: 9    // small labels
	readonly property int fontBase: 13 // body text
	readonly property int fontLg: 16   // icon buttons
	readonly property int fontXl: 24   // large text & icons
	readonly property int font3xl: 80  // clock

	// Spacing scale
	readonly property int spaceXs: 6
	readonly property int spaceSm: 8
	readonly property int spaceMd: 16

	// Text colors (fg at descending opacities)
	readonly property color textPrimary: Qt.rgba(1, 1, 1, 0.7)
	readonly property color textStatus: Qt.rgba(1, 1, 1, 0.55)
	readonly property color textSecondary: Qt.rgba(1, 1, 1, 0.5)
	readonly property color textMuted: Qt.rgba(1, 1, 1, 0.4)
	readonly property color textHint: Qt.rgba(1, 1, 1, 0.35)
	readonly property color textDisabled: Qt.rgba(1, 1, 1, 0.3)
	readonly property color textTertiary: Qt.rgba(1, 1, 1, 0.15)

	// Surface colors (white overlays)
	readonly property color surfaceBg: Qt.rgba(1, 1, 1, 0.1)
	readonly property color surfaceButton: Qt.rgba(1, 1, 1, 0.08)
	readonly property color surfaceDisabled: Qt.rgba(1, 1, 1, 0.05)
	readonly property color spinnerStroke: Qt.rgba(1, 1, 1, 0.6)

	// Background layers
	readonly property real bgImageOpacity: 0.6
	readonly property real overlayOpacity: 0.3

	// Component sizing
	readonly property int passwordWidth: 200
	readonly property int passwordPadding: 12
	readonly property int passwordRadius: 6
	readonly property int spinnerSize: 24
	readonly property int spinnerMargin: 2
	readonly property int spinnerStrokeWidth: 2
	readonly property int buttonSize: 48

	// Layout positions
	readonly property int clockTopOffset: 60
	readonly property int marginHintBottom: 60
	readonly property int marginCancelBottom: 40

	// Global animation duration (ms)
	readonly property int animDuration: 600

	// Timer intervals (ms)
	readonly property int timerInterval: 1000
}
