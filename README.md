# CachyOS Toolkit

Configuration tools for CachyOS. Portable: uses relative paths (`$HOME`,
`/etc`) and doesn't depend on any specific machine.

## Scripts (`bin/`)

### `cachyos-assistant`
Interactive menu-driven assistant. Run it with no arguments:

```bash
cachyos-assistant
```

Navigate with the **arrow keys** (↑/↓ move, Enter selects, Space ticks items in
the multi-select install menus, `q`/Esc go back) — or just type the number/letter
as a shortcut. On first run it asks the language and the navigation mode; both
can be changed later (language and *Configuration › Navigation mode*). The
classic *numbers* mode is also a fallback for terminals where arrow keys misbehave.

Sections:
- **Install applications** — by category. Prefers **CachyOS-optimized**
  packages (`x86-64-v3/v4` repos; for gaming it uses `cachyos-gaming-meta`,
  `wine-cachyos`, `proton-cachyos`).
  - *Games* (complete).
  - *Development*: complete **Packs** by stack (Web, Java, Rust, Python, Go,
    C/C++, .NET, Containers, XAMPP) and **individual install** by type
    (Editors/IDEs, Languages, Databases, Tools/DevOps).
  - *Multimedia* (playback: VLC, MPV, Spotify, FFmpeg).
  - *Streaming and VTubing*: OBS Studio, the itch.io client (to install
    veadotube-mini), Inochi Session/Creator, Chatterino, Streamlink.
  - *Editing* (video, photo, audio): DaVinci Resolve, Kdenlive, Shotcut,
    OpenShot, Blender, GIMP, Krita, Inkscape, darktable, Audacity…
  - *Office*, *Internet* and *System & utilities*.
  - Selecting an app offers «Install now», «Uninstall» or «Add to the list».
  - **Installation list**: accumulate apps from several categories into a
    selection and then **install all** or **uninstall all** at once (with
    options to remove an item or clear it).
- **Configuration** — fixes and tweaks by category (Network, Keyboard,
  Mirrors & packages), a **default web browser** picker (detects the installed
  browsers and sets the default with `xdg-settings`), and **Updates &
  maintenance** (pre-update safety check, safe system update, boot/kernel repair
  and obsolete-kernel cleanup). Uses `cachyos-fix` as the engine for the fixes.
- **Services** — a service/session manager built **dynamically** from systemd
  (nothing hardcoded). It spans both the **system** manager (actions use `sudo`)
  and the **user session** (`systemctl --user`, no `sudo`), with filters:
  - *apps* (default) — the applications launched this session (Discord, Steam,
    Brave…), shown with their friendly name; they run as `app-*` user units.
  - *running* / *autostart* / *failed* / *all* — system services.
  - *system* — low-level OS services (systemd's own units, `dbus`, `polkit`,
    template units…), hidden from the other filters.

  You can turn entries on/off, restart them and set autostart at boot; each
  shows its live state. You can also type any unit by name. XAMPP is a special
  case: since it can run outside systemd (its own `/opt/lampp` control script),
  its state is read from the real processes and it is started/stopped through
  that script, while autostart is set up via a generated systemd unit.
- **System status**.

It auto-detects `paru`/`yay`/`pacman`.

### `cachyos-fix`
Fix engine, idempotent. Direct usage:

```bash
cachyos-fix [all|keyboard|numlock|fnkeys|wifi|mirrors|preupdate|update|repair-boot|status]
```

(Spanish aliases still work: `teclado`, `estado`, `mirror`.)

- **keyboard** — forces the `es` layout in X11/Xwayland apps (it produced `@`
  with Shift+2 when falling back to `us`). Accepts a layout code
  (`cachyos-fix keyboard fr`). Autostart in `~/.config/autostart/`.
- **numlock** `[on|off|unchanged]` — sets the numeric keypad behavior at login
  (KDE) and applies it live with `numlockx`. `on` (default) keeps it on, `off`
  keeps it off, `unchanged` leaves it to the firmware/last state.
- **fnkeys** `[fkeys|media|auto]` — sets the Fn / F1–F12 top-row behavior via
  the `hid_apple` `fnmode` (persistent + live). Only applies to keyboards using
  that driver (Apple/«Magic» and some others); on most laptops the Fn behavior
  is firmware/BIOS-controlled, and the fix says so instead of changing anything.
- **wifi** — disables power saving on the `rtw88` driver (RTL8822BE), the
  cause of the disconnections (BEACON-LOSS). Writes to `/etc/…`, regenerates
  initramfs and reloads the driver only when needed.
- **mirrors** — reorders the mirror list (`cachyos-rate-mirrors`, with
  `rate-mirrors`/`reflector` as a fallback) and forces `pacman -Syy`. Fixes
  the 404 errors on update when mirrors are out of sync.
- **preupdate** — pre-update safety check: makes sure `/boot` is mounted (mounts
  it if `fstab` expects it, otherwise aborts) and clears a stale `db.lck` (only
  when no `pacman` is running). Prevents kernel/module drift and lock errors.
- **update** — safe update: runs `preupdate` and, if it passes, `pacman -Syu`.
- **repair-boot** — repairs a broken boot after a kernel mess: removes orphan
  `/usr/lib/modules/<ver>` folders of kernels no longer installed (the running
  kernel is protected; ownership is checked via `pacman -Ql`, not the
  path-resolving `pacman -Qo`), then runs `depmod`, `dkms autoinstall` and
  `mkinitcpio -P`.
- **clean-kernels** — lighter cleanup: lists the obsolete `/usr/lib/modules`
  folders (with their size) and removes them all (running kernel protected),
  refreshing `depmod` only. Does not rebuild DKMS/initramfs.

## Install

Download the installer from the [latest release](../../releases/latest) and run
it (a small menu with **Install** / **Uninstall**):

```bash
curl -fsSL https://github.com/Jorgeescribanogarcia/cachyos-toolkit/releases/latest/download/install.sh -o install.sh
bash install.sh
```

**Install** downloads the toolkit into `~/.local/share/cachyos-toolkit` (a git
clone), and registers a `cachyos-toolkit` command in `~/.local/bin` plus an app
launcher, so it shows up in the application menu / KRunner (Alt+Space) as
**CachyOS Toolkit** and opens in a terminal. Everything is user-level (no root).
**Uninstall** removes all of it, including the downloaded folder.

Because the install is a git clone, on every launch the assistant quietly checks
for a newer version and offers to update (`git pull`) — keeping the command and
launcher current. There is also a manual *Check for updates* in the main menu's
*Install this toolkit as an app* screen. Set `CACHYOS_NO_UPDATE_CHECK=1` to skip
the automatic check.

### Manual / from a clone

You can also just clone and run it, then use **Install this toolkit as an app**
from the main menu to register the current clone:

```bash
git clone https://github.com/Jorgeescribanogarcia/cachyos-toolkit.git
./cachyos-toolkit/bin/cachyos-assistant
```

Neither script should be run as root; they ask for `sudo` when they need it.

