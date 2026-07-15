# CachyOS Toolkit

Configuration tools for CachyOS. Portable: uses relative paths (`$HOME`,
`/etc`) and doesn't depend on any specific machine.

The UI is **bilingual (English / Spanish)**. See [Language](#language) below.

## Scripts (`bin/`)

### `cachyos-assistant`
Interactive menu-driven assistant. Run it with no arguments:

```bash
cachyos-assistant
```

Sections:
- **Install applications** — by category. Prefers **CachyOS-optimized**
  packages (`x86-64-v3/v4` repos; for gaming it uses `cachyos-gaming-meta`,
  `wine-cachyos`, `proton-cachyos`).
  - *Games* (complete).
  - *Development*: complete **Packs** by stack (Web, Java, Rust, Python, Go,
    C/C++, .NET, Containers, XAMPP) and **individual install** by type
    (Editors/IDEs, Languages, Databases, Tools/DevOps).
  - *Multimedia*, *Office*, *Internet* and *System & utilities*.
  - **Installation list**: in any category you can «Install now» (direct flow)
    or «Add to the list» to accumulate apps from several categories and
    install them all at once (with options to remove or clear).
- **Configuration** — fixes and tweaks by category (Network, Keyboard,
  Mirrors & packages). Uses `cachyos-fix` as the engine.
- **System status**.

It auto-detects `paru`/`yay`/`pacman`.

### `cachyos-fix`
Fix engine, idempotent. Direct usage:

```bash
cachyos-fix [all|keyboard|numlock|wifi|mirrors|status]
```

(Spanish aliases still work: `teclado`, `estado`, `mirror`.)

- **keyboard** — forces the `es` layout in X11/Xwayland apps (it produced `@`
  with Shift+2 when falling back to `us`). Accepts a layout code
  (`cachyos-fix keyboard fr`). Autostart in `~/.config/autostart/`.
- **numlock** — keeps Num Lock on: KDE at login + `numlockx` live.
- **wifi** — disables power saving on the `rtw88` driver (RTL8822BE), the
  cause of the disconnections (BEACON-LOSS). Writes to `/etc/…`, regenerates
  initramfs and reloads the driver only when needed.
- **mirrors** — reorders the mirror list (`cachyos-rate-mirrors`, with
  `rate-mirrors`/`reflector` as a fallback) and forces `pacman -Syy`. Fixes
  the 404 errors on update when mirrors are out of sync.

## Language

The interface language is resolved in this order:

1. `CACHYOS_LANG` environment variable (`en` or `es`).
2. Saved choice in `~/.config/cachyos-toolkit/lang`.
3. System locale (`LANG`): Spanish → `es`, otherwise `en`.

On first run the assistant asks for the language and remembers it. You can
change it any time from the main menu (option **Language / Idioma**). The
assistant passes the chosen language to `cachyos-fix` automatically.

## Install on another CachyOS machine

```bash
git clone <repo> ~/Escritorio/cachyos-toolkit
ln -sf ~/Escritorio/cachyos-toolkit/bin/cachyos-assistant ~/.local/bin/
ln -sf ~/Escritorio/cachyos-toolkit/bin/cachyos-fix       ~/.local/bin/
```

Neither should be run as root; they ask for `sudo` when they need it.
