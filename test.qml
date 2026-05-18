import QtQuick
import Quickshell

ShellRoot {
	Config {
		id: config
	}

	LockContext {
		id: lockContext
		config: config
		onUnlocked: Qt.quit();
	}

	FloatingWindow {
		LockSurface {
			anchors.fill: parent
			context: lockContext
			config: config
		}
	}

	// exit the example if the window closes
	Connections {
		target: Quickshell

		function onLastWindowClosed() {
			Qt.quit();
		}
	}
}
