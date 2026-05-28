# Nightfox Theme

A deep blue-gray theme for quicklock inspired by the [Nightfox](https://github.com/EdenEast/nightfox.nvim) colorscheme.

## Colors

| Property | Color | Usage |
|---|---|---|
| `bg` | `#192330` | Background |
| `textPrimary` | `#e4cfff` | Clock, date, password |
| `textStatus` | `#f4a261` | Status messages |
| `textSecondary` | `#63cdcf` | Fingerprint subtitle |
| `textMuted` | `#81b29a` | Hint text |
| `textHint` | `#d67ad2` | Labels |
| `error` | `#c94f6d` | Auth failure |
| `spinnerStroke` | `#d67ad2` | Loading spinner |

## Wallpaper

![Nightfox wallpaper](preview.jpg)

## Usage

```bash
ln -sf themes/nightfox/nightfox.config.json config.json
```

Note: by default `bgImageOpacity` is set to `0.0` for a solid background. Set it to `0.6` to show the wallpaper.
