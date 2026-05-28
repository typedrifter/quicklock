# Quicklock

A simple lock screen for Wayland, built with [Quickshell](https://guickshell.org).

## What it does

Locks your session and displays a simple clock with date as a lockscreen. 
Supports both fingerprint readers and password fallback via PAM.

## Usage


```
git clone https://github.com/FLchs/quicklock.git .config/quickshell/quicklock
qs -c quicklock
```

## Requirements

- A Wayland compositor that supports the ext-session-lock protocol
- Quickshell installed and working
- PAM configured on your system

## Demos

### Password Authentication

![quicklock password demo](demo_password.gif)

### Fingerprint Authentication

![quicklock fingerprint demo](demo_fingerprint.gif)

## Security disclaimer

Consider this alpha software. There may be bugs, and it has not been thoroughly audited. It relies on your Wayland compositor to enforce the session lock. If the compositor does not properly implement the ext-session-lock protocol, the screen may not be fully secured. Always verify that your compositor handles session locking correctly before relying on this in sensitive environments.

## Configuration

PAM config lives in the `pam/` directory. The default config uses `password.conf`. Adjust to your system as needed.

## Themes

Themes live in the `themes/` directory. Each theme has its own folder containing a `<name>.theme.json` file and a `wallpaper.jpg`.

The active theme is selected in `config.json` at the project root:

```json
{
  "theme": "sleek",
  "pamConfig": "password.conf",
  "timeout": 30,
  "showDate": true,
  "showHint": true,
  "clock24h": true
}
```

All fields are optional and fall back to sensible defaults if omitted.

| Field | Default | Description |
|---|---|---|
| `theme` | `sleek` | Theme name (must match a folder in `themes/`) |
| `pamConfig` | `password.conf` | PAM configuration file. Relative paths are resolved inside the `pam/` directory; absolute paths (e.g. `/etc/pam.d/system-auth`) are used as-is. |
| `timeout` | `30` | Seconds before cancelling an authentication attempt |
| `showDate` | `true` | Show the date label above the clock |
| `showHint` | `true` | Show the "Click or press any key to unlock" hint |
| `clock24h` | `true` | Use 24-hour clock format (set to `false` for 12-hour) |

Available themes:
- `sleek` — default dark minimal theme
- `catppuccin` — soft pastel Catppuccin Mocha palette
- `tokyonight` — dark neon Tokyo Night palette
- `nightfox` — deep blue-gray Nightfox palette

If the configured theme is missing or broken, the lockscreen falls back to the built-in `sleek` defaults.

### Creating a custom theme

Copy an existing theme folder, rename it, and adjust the colors in the `.theme.json` file. Only visual tokens need to be defined — layout, sizing, and animation defaults are handled automatically:

```json
{
  "bg": "#1e1e2e",
  "fg": "#cdd6f4",
  "error": "#f38ba8",
  "fontFamily": "monospace",
  "textPrimary": "#f5c2e7",
  "textSecondary": "#89b4fa",
  "textMuted": "#94e2d5",
  "surfaceBg": "#313244",
  "spinnerStroke": "#cba6f7",
  "wallpaper": "themes/mytheme/wallpaper.jpg"
}
```

Advanced users can still override any layout or animation property by adding it to the theme JSON (the keys match the QML properties in `Config.qml`).

## Development

Run `qs -p ./test.qml` to preview the lock screen in a floating window without actually locking your session. Useful for tweaking the UI.

## Credits

Base code adapted from the [Quickshell examples repository](https://github.com/quickshell-mirror/quickshell-examples).

Background photo by Lauri Poldre, sourced from [Pexels](https://www.pexels.com/photo/lush-coniferous-forest-with-tall-evergreen-trees-30197098/).

