# `cachyos-fix` — function reference

[← Index](README.md)

The idempotent fix engine. It resolves the language (`CACHYOS_LANG` → saved file
→ locale), refuses to run as root, then dispatches on the first argument:

```
cachyos-fix [all|keyboard|numlock|fnkeys|wifi|mirrors|preupdate|update|repair-boot|clean-kernels|status]
```

Spanish aliases still work (`teclado`, `estado`, `mirror`, `espejos`,
`bloqnum`…). `all` runs `keyboard`, `numlock`, `wifi` and `status`; `mirrors`,
`preupdate`, `update`, `repair-boot` and `clean-kernels` are **not** in `all`
(they are heavier / interactive and opt-in).

---

## i18n & output helpers

### `detect_system_lang`
- **Signature:** `detect_system_lang`
- **What it does:** guesses the UI language from `LC_ALL`/`LC_MESSAGES`/`LANG`.
- **Output:** prints `es` for Spanish locales, otherwise `en`.

### `t`
- **Signature:** `t <key>`
- **What it does:** translates a message key using the `MSG_${UI_LANG^^}`
  associative array.
- **Output:** the localized string; falls back to `MSG_EN[key]`, then to the
  raw key.

### `log` / `ok` / `warn` / `err`
- **Signature:** `log|ok|warn|err <message>`
- **What they do:** colored status lines — `log` a blue `==>` step, `ok` a green
  `✔`, `warn` a yellow `!`, `err` a red `✗` (to **stderr**).

### `write_root_file`
- **Signature:** `write_root_file <path> <content>`
- **What it does:** writes `content` to a root-owned `path` via `sudo tee`, but
  **only if it differs** from the current content (compared with `sudo cmp`).
- **Returns:** `0` if it wrote/changed the file, `1` if it was already identical.
- **Notes:** lets callers know whether a change happened (e.g. whether to
  regenerate initramfs).

---

## Fix: keyboard

### `fix_keyboard`
- **Signature:** `fix_keyboard [layout]` (default `es`)
- **What it does:** forces the keyboard layout in X11/Xwayland apps, in three
  layers: (1) system default via `sudo localectl set-x11-keymap`; (2) a backup
  `~/.config/autostart/fix-keyboard-layout.desktop` running `setxkbmap`
  (KDE Wayland's KWin can otherwise override the system layout for Xwayland);
  (3) live application in the current session with `setxkbmap`.
- **Writes:** `/etc/X11/xorg.conf.d` (via localectl), the autostart file; removes
  the old `fix-keyboard-es.desktop`.
- **Notes:** solves apps like VS Code falling back to `us` (Shift+2 → `@`).

---

## Fix: Num Lock

### `fix_numlock`
- **Signature:** `fix_numlock [on|off|unchanged]` (default `on`, backward
  compatible)
- **What it does:** sets the numeric keypad behavior at login and applies it
  live. Maps the mode to KDE's `kcminputrc` `[Keyboard] NumLock` value
  (`on`→0, `off`→1, `unchanged`→2) via `kwriteconfig6`/`kwriteconfig5`. For
  `on`/`off` it also applies live with `numlockx` (installing it from the
  official repos if missing); `unchanged` performs no live change.
- **Writes:** `kcminputrc`; may install `numlockx`.

---

## Fix: Fn keys

### `fix_fnkeys`
- **Signature:** `fix_fnkeys [fkeys|media|auto]` (default `fkeys`)
- **What it does:** sets the top-row Fn behavior through the `hid_apple` driver's
  `fnmode` (`fkeys`→2, `media`→1, `auto`→3). Persists it in
  `/etc/modprobe.d/hid_apple.conf` and applies it live by writing
  `/sys/module/hid_apple/parameters/fnmode`.
- **Notes:** **defensive** — if `/sys/module/hid_apple` does not exist (most
  laptops, where the Fn behavior is firmware/BIOS-controlled) it warns and does
  nothing instead of writing junk.

---

## Fix: WiFi

### `detect_wifi`
- **Signature:** `detect_wifi`
- **What it does:** finds the first wireless interface and its driver by walking
  `/sys/class/net/*/wireless`.
- **Output/Returns:** prints `"<iface> <driver>"` and returns `0`; returns `1`
  if there is no WiFi interface.

### `fix_wifi`
- **Signature:** `fix_wifi`
- **What it does:** fixes rtw88 disconnections (BEACON-LOSS). Turns power-saving
  off in NetworkManager (generic, `wifi-powersave-off.conf`); for the rtw88
  family it also writes `/etc/modprobe.d/rtw88.conf`
  (`disable_aspm=1`, `disable_lps_deep=1`), regenerates the initramfs
  (`mkinitcpio -P`) only if that file changed, and reloads the driver only if the
  parameters are not already applied (so it won't drop the connection needlessly).
- **Writes:** the two `.conf` files; may regenerate initramfs and reload the
  module. Uses `detect_wifi`.

---

## Fix: mirrors

### `fix_mirrors`
- **Signature:** `fix_mirrors`
- **What it does:** reorders the pacman mirror list to keep the fastest/most
  up-to-date mirrors, then forces `pacman -Syy`. It prefers
  `cachyos-rate-mirrors`, then `rate-mirrors`, then `reflector`; if none is
  installed it offers to install the recommended `cachyos-rate-mirrors`.
- **Notes:** fixes 404 errors on update caused by out-of-sync mirrors.

---

## Boot / kernel helpers

### `boot_in_fstab`
- **Signature:** `boot_in_fstab`
- **What it does:** checks whether `/etc/fstab` declares a separate `/boot`
  partition (a non-comment line whose mount point, field 2, is `/boot`).
- **Returns:** `0` if declared, `1` otherwise.

### `check_boot`
- **Signature:** `check_boot`
- **What it does:** ensures `/boot` is usable. If it is already mounted → OK. If
  `boot_in_fstab` says it should be but it isn't → tries `sudo mount /boot`. If
  there is no separate `/boot` (it lives on the root fs) → OK.
- **Returns:** `0` if mounted or on-root, `1` if it should be mounted but could
  not be. Prints the status.

### `orphan_modules`
- **Signature:** `orphan_modules`
- **What it does:** prints, one per line, the `/usr/lib/modules/<ver>` folders
  left behind by kernels that are no longer installed. The **running kernel**
  (`uname -r`) is never included.
- **How it decides:** reads each folder's `pkgbase` marker (the package that
  created it) and confirms with `pacman -Ql <pkg>` that this exact version is in
  that package's file list; if not, it is an orphan.
- **Notes:** it deliberately does **not** use `pacman -Qo`, which canonicalizes
  paths and would report a *different* installed version as the owner of a
  leftover folder — hiding real orphans, the very failure this catches.

---

## Fix: pre-update & update

### `fix_preupdate`
- **Signature:** `fix_preupdate`
- **What it does:** the pre-update safety check. Runs `check_boot`, then inspects
  `/var/lib/pacman/db.lck`: if a `pacman` process is running the lock is
  legitimate (it warns and marks the system unsafe); if it is a stale lock it
  offers to remove it.
- **Returns:** `0` if it is safe to update, `1` otherwise.

### `fix_update`
- **Signature:** `fix_update`
- **What it does:** the safe update — runs `fix_preupdate` and, only if it
  passes, offers to run `sudo pacman -Syu`.

---

## Fix: repair boot & clean kernels

### `fix_repair_boot`
- **Signature:** `fix_repair_boot`
- **What it does:** repairs a broken boot after a kernel mess. Requires `/boot`
  mounted (`check_boot`), lists the orphans (`orphan_modules`) and — after
  confirmation — removes each `/usr/lib/modules/<ver>` (protecting the running
  kernel), then runs `depmod` per remaining kernel, `dkms autoinstall` (if DKMS
  is present) and `mkinitcpio -P`.
- **Notes:** guarded removal (`${moddir:?}` plus a re-check that the version is
  not the running one).

### `fix_clean_kernels`
- **Signature:** `fix_clean_kernels`
- **What it does:** the lighter cleanup. Lists the orphan module folders with
  their size (`du -sh`), and — with a default-**No** confirmation — removes them
  all (running kernel protected), then refreshes `depmod` for the running kernel.
  It does **not** rebuild DKMS or initramfs (that is `repair-boot`'s job).

---

## Status

### `status`
- **Signature:** `status`
- **What it does:** prints the current state without changing anything: keyboard
  layout (system + Xwayland), Num Lock (KDE), Fn keys (if `hid_apple` is
  present), WiFi (interface, driver, power-save and — for rtw88 — the module
  parameters), whether `/boot` is mounted, and the number of orphan kernel-module
  folders.
