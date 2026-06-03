import Quickshell
import Quickshell.Wayland

ShellRoot {
	Config {
		id: config
	}

	// This stores all the information shared between the lock surfaces on each screen.
	LockContext {
		id: lockContext
		config: config

		onUnlocked: {
			// Unlock the screen before exiting, or the compositor will display a
			// fallback lock you can't interact with.
			lock.locked = false;

			Qt.quit();
		}
	}

	WlSessionLock {
		id: lock

		// Lock the session immediately when quickshell starts.
		locked: true

		WlSessionLockSurface {
			LockSurface {
				anchors.fill: parent
				context: lockContext
				config: config
			}
		}
	}
}
