# `cachyos-assistant` — function reference

[← Index](README.md)

The interactive assistant. This reference documents every function, grouped by
category. See [Architecture](architecture.md) for the i18n and navigation
systems these build on.

> **Catalog data.** The application catalog is held in parallel arrays, not
> functions: for each category `X` there is `X_NAMES` (display names), `X_PKGS`
> (packages, space-separated groups allowed) and `X_DESC_EN` / `X_DESC_ES`
> (descriptions), all aligned by index. `PACKS` additionally has `PACKS_NAMES_EN`
> / `PACKS_NAMES_ES`. To add an app, align the four arrays by index.

---

## i18n & settings

### `detect_system_lang`
- **Signature:** `detect_system_lang` — prints `es`/`en` from the locale.

### `load_lang`
- **Signature:** `load_lang`
- **What it does:** resolves `UI_LANG` (`CACHYOS_LANG` env → `~/.config/cachyos-toolkit/lang` → system locale → `en`) and records where it came from in `LANG_SOURCE` (`env`/`file`/`default`).

### `save_lang`
- **Signature:** `save_lang` — persists `UI_LANG` to the `lang` file.

### `load_nav`
- **Signature:** `load_nav`
- **What it does:** resolves `NAV_MODE` (`CACHYOS_NAV` env → `~/.config/cachyos-toolkit/nav` → default `arrows`) and records `NAV_SOURCE`.

### `save_nav`
- **Signature:** `save_nav` — persists `NAV_MODE` to the `nav` file.

### `t`
- **Signature:** `t <key>` — returns the localized string (`MSG_${UI_LANG^^}`, falling back to `MSG_EN`, then the key).

---

## Style & helpers

### `header`
- **Signature:** `header [subtitle]`
- **What it does:** clears the screen and prints the cyan title box (`app_title`
  on the first line, `subtitle` on the second).

### `ok` / `warn` / `err`
- **Signature:** `ok|warn|err <message>` — colored status lines (`err` → stderr).

### `pause`
- **Signature:** `pause` — prints "Press Enter…" and waits for a line.

### `confirm`
- **Signature:** `confirm <question>`
- **Returns:** `0` if the answer matches `[sSyY]`, non-zero otherwise.

---

## Navigation

### `menu_pick`
- **Signature:** `menu_pick <title> <keys_array> <labels_array> [back_key]`
- **What it does:** renders a single-choice menu and stores the chosen key in the
  global **`MENU_RESULT`**. In `arrows` mode: ↑/↓ (or `k`/`j`) move, Enter picks
  the highlighted row (`▸`), pressing a row's key selects it directly, `q`/Esc/←
  return `back_key` (default `0`). In `numbers` mode: prints the list and reads a
  typed key/line. An optional info line is shown from the global **`MENU_INFO`**.
- **Notes:** callers pass parallel `keys`/`labels` arrays and then `case` on
  `MENU_RESULT`, so the same `case` handles both navigation modes.

### `menu_pick_multi`
- **Signature:** `menu_pick_multi <title> <labels_array>`
- **What it does:** a checkbox (multi-choice) menu. Sets **`MULTI_ACTION`** to
  `ok` (≥1 ticked), `empty` (Enter with nothing ticked), `list` (`L`), or
  `cancel` (`q`/Esc/←/`0`), and **`MULTI_SEL`** to the 0-based selected indices.
  Arrows mode: ↑/↓ move, Space (or a digit) toggles, `a` toggles all, Enter
  confirms; numbers mode: classic "type 1 3 5", `a`=all, `L`=list, `0`=back.

---

## Install engine

### `detect_helper`
- **Signature:** `detect_helper` — prints `paru`, `yay` or `pacman`.

### `ensure_base_devel`
- **Signature:** `ensure_base_devel`
- **What it does:** makes sure the AUR build environment (`base-devel` + `git`)
  is present, installing what is missing with pacman.
- **Returns:** `0` if ready, `1` if it could not install them.

### `install_paru`
- **Signature:** `install_paru`
- **What it does:** when there is no AUR helper, offers to install `paru` — first
  from the CachyOS repos, otherwise by building `paru-bin` from AUR (needs
  `ensure_base_devel`).
- **Returns:** `0` if paru ends up installed.

### `install_packages`
- **Signature:** `install_packages <pkg...>`
- **What it does:** installs packages. If there is no AUR helper it offers
  `install_paru` first; shows what will be installed, asks `confirm`, then runs
  `pacman -S --needed` (official only) or `<helper> -S --needed --skipreview`
  (after `ensure_base_devel`). `--skipreview` avoids the PKGBUILD pager that
  aborted installs (e.g. VS Code).

### `uninstall_packages`
- **Signature:** `uninstall_packages <pkg...>`
- **What it does:** removes packages. Filters the list to the ones actually
  installed (`pacman -Qq`), warns if none are, confirms, then runs
  `sudo pacman -Rns`. No AUR helper is needed (AUR packages are regular packages
  once installed).

---

## Installation list

Global parallel arrays `LIST_NAMES` / `LIST_PKGS` hold a cross-category selection.

### `list_add`
- **Signature:** `list_add <name> <pkgs>` — appends to the list, skipping
  duplicates (by package group).

### `list_show`
- **Signature:** `list_show` — prints the queued entries (name + packages).

### `list_install`
- **Signature:** `list_install` — flattens the package groups and installs them
  all (`install_packages`); clears the list on success.

### `list_uninstall`
- **Signature:** `list_uninstall` — same, but `uninstall_packages`; clears on
  success.

### `list_menu`
- **Signature:** `list_menu`
- **What it does:** the list-management screen (via `menu_pick`): install ALL,
  uninstall ALL, remove an item (by number), clear. Shows the queued items as the
  info block. Empty list → a hint + returns.

---

## Applications section

### `category_menu`
- **Signature:** `category_menu <label> <names_array> <pkgs_array> <desc_base>`
  (the description array used is `${desc_base}_${UI_LANG^^}`)
- **What it does:** the multi-select install menu for a category. Uses
  `menu_pick_multi` to tick apps, then offers, via `menu_pick`: install now, add
  to the list, or uninstall the ticked apps. `L` opens `list_menu`; back returns.

### `dev_individual_menu`
- **Signature:** `dev_individual_menu` — sub-navigation for Development ›
  Individual (Editors, Languages, Databases, Tools), each opening a
  `category_menu`.

### `dev_section`
- **Signature:** `dev_section` — Development menu: Packs (a `category_menu` over
  `PACKS_*`) or Individual (`dev_individual_menu`).

### `apps_section`
- **Signature:** `apps_section`
- **What it does:** the top-level "Install applications" menu: the eight
  categories, plus `L` to open the installation list.

---

## Configuration & fixes

### `has_cachyos_fix`
- **Signature:** `has_cachyos_fix` — returns `0` if `cachyos-fix` is available.

### `run_fix`
- **Signature:** `run_fix <args...>` — runs `cachyos-fix` passing the UI language
  through `CACHYOS_LANG`.

### `apply_fix`
- **Signature:** `apply_fix <subcommand> <description> [extra args...]`
- **What it does:** shows the description, asks `confirm`, and on yes runs
  `run_fix <subcommand> [extra args]`. Handles "fix not found".

### `choose_layout`
- **Signature:** `choose_layout`
- **What it does:** keyboard-layout chooser (Spanish, US, Latin America, French…,
  plus "type a code"). Prints the chosen layout code on **stdout** (the menu goes
  to stderr, so it can be captured as `lay=$(choose_layout)`); empty = cancel.

### `choose_numlock`
- **Signature:** `choose_numlock` — prints `on`/`off`/`unchanged` (menu to
  stderr); empty = cancel.

### `choose_fnkeys`
- **Signature:** `choose_fnkeys` — prints `fkeys`/`media`/`auto`; empty = cancel.

> These three still use classic prompts (they are captured with `$(…)`, which
> conflicts with the redraw-based `menu_pick`).

### `config_section`
- **Signature:** `config_section`
- **What it does:** the Configuration menu (Network, Keyboard, Mirrors, Default
  browser, Updates & maintenance, Navigation mode, Apply ALL fixes).

### `fix_network_menu`
- **Signature:** `fix_network_menu` — offers the WiFi fix (`apply_fix wifi`).

### `fix_keyboard_menu`
- **Signature:** `fix_keyboard_menu` — Keyboard menu: layout (`choose_layout` →
  `apply_fix keyboard`), Num Lock behavior (`choose_numlock` → `apply_fix
  numlock`), Fn behavior (`choose_fnkeys` → `apply_fix fnkeys`).

### `fix_mirrors_menu`
- **Signature:** `fix_mirrors_menu` — offers the mirrors refresh
  (`apply_fix mirrors`).

### `fix_maintenance_menu`
- **Signature:** `fix_maintenance_menu` — Updates & maintenance: pre-update
  check, safe update, repair boot, and view/remove obsolete kernels — each an
  `apply_fix` of the matching `cachyos-fix` subcommand.

---

## Default browser

### `detect_browsers`
- **Signature:** `detect_browsers`
- **What it does:** scans the `.desktop` files (in the system, user and Flatpak
  application dirs) and prints `"<desktop-id>\t<Name>"` for each entry that
  registers the `http(s)` URL scheme (excluding hidden/no-display ones).

### `browser_name`
- **Signature:** `browser_name <desktop-id>` — maps an id to its friendly Name
  (falls back to the id).

### `config_browser_menu`
- **Signature:** `config_browser_menu`
- **What it does:** the default-browser picker. Ensures `xdg-settings`
  (offers to install `xdg-utils`), lists the detected browsers (via `menu_pick`,
  showing the current default), and applies the choice with
  `xdg-settings set default-web-browser`.

---

## Self-install & updates

Globals: `APP_SELF` (real assistant path), `APP_BIN` (`~/.local/bin/cachyos-toolkit`),
`APP_DESKTOP` (the launcher).

### `app_is_installed`
- **Signature:** `app_is_installed` — returns `0` if the command symlink or the
  `.desktop` exists.

### `install_app_do`
- **Signature:** `install_app_do`
- **What it does:** registers the toolkit as an app — a `cachyos-toolkit` symlink
  in `~/.local/bin` → the assistant, and a `.desktop` launcher (`Terminal=true`,
  absolute `Exec`, `Categories=System;`) — then `update-desktop-database` and a
  PATH hint. Both point into the repo (no copy), so `git pull` keeps them current.

### `install_app_undo`
- **Signature:** `install_app_undo` — removes the symlink and the `.desktop`
  (clean uninstall).

### `install_app_menu`
- **Signature:** `install_app_menu`
- **What it does:** the "Install this toolkit as an app" screen. When installed,
  "Install" is dimmed and only "Uninstall" acts (and vice-versa). Also offers a
  manual **Check for updates** (`run_update_check manual`).

### `run_update_check`
- **Signature:** `run_update_check [auto|manual]`
- **What it does:** if the toolkit is a git clone with an upstream, fetches (with
  a timeout, never prompting) and compares with the remote. If behind, offers
  `git pull --ff-only` and, on success, restarts via `exec`. `auto` (startup) is
  silent unless there is an update and is skipped by `CACHYOS_NO_UPDATE_CHECK`;
  `manual` always reports the result (up to date / offline / not a clone).

---

## System status

### `status_section`
- **Signature:** `status_section` — runs `cachyos-fix status` (or a minimal
  fallback if the engine is missing).

---

## Services manager

### `svc_filter_scope`
- **Signature:** `svc_filter_scope <filter>` — prints `user` for `apps`/`user`
  filters, otherwise `system`. Determines which systemd manager (and whether
  `sudo`) the actions use.

### `svc_known`
- **Signature:** `svc_known <scope> <unit>` — returns `0` if the unit is known to
  that manager (`systemctl [--user] cat`).

### `svc_list_units`
- **Signature:** `svc_list_units <filter>`
- **What it does:** lists unit names for a filter, sorted case-insensitively —
  `apps` (running `app-*` user units), `running`/`failed` (system, `list-units`),
  `enabled`/`all`/`system` (system, `list-unit-files`).

### `svc_is_system`
- **Signature:** `svc_is_system <unit>`
- **What it does:** heuristic classifier — returns `0` for OS/plumbing services
  (`systemd-*`, template `*@*` units, `dbus`, `polkit`, `udisks2`, `avahi`,
  display managers, `cachyos-*`…), which are hidden from the normal filters and
  shown only under `system`.

### `svc_next_filter`
- **Signature:** `svc_next_filter <filter>` — the cycle
  apps → running → enabled → failed → all → system → apps.

### `svc_filter_name`
- **Signature:** `svc_filter_name <filter>` — the localized filter label.

### `svc_load_states`
- **Signature:** `svc_load_states <scope>`
- **What it does:** bulk-loads, in two `systemctl` calls, every unit's active
  state (`SVC_ACTIVE`), enabled state (`SVC_ENABLED`) and description
  (`SVC_DESC`) for the manager, so painting a long list needs no per-unit calls.

### `_svc_render_badges`
- **Signature:** `_svc_render_badges <active-state> <enabled-state>` — renders
  the colored "state · autostart" badge from raw states.

### `svc_badges`
- **Signature:** `svc_badges <scope> <unit>` — live badges for one unit (used in
  the action menu; queries `systemctl` fresh).

### `svc_badges_row`
- **Signature:** `svc_badges_row <unit>` — badges from the cached
  `SVC_ACTIVE`/`SVC_ENABLED` maps (used to paint the list fast).

### `svc_app_label`
- **Signature:** `svc_app_label <unit> <raw-description>`
- **What it does:** a friendly name for a user/app unit — the systemd
  Description, or (when missing) a name derived from the unit id
  (`app-org.kde.konsole-2123.scope` → `konsole`).

### `svc_isenabled`
- **Signature:** `svc_isenabled <scope> <unit>` — the raw `is-enabled` value.

### `svc_run`
- **Signature:** `svc_run <scope> <unit> <action>` — runs the systemctl action
  (`sudo systemctl` for system, `systemctl --user` for user) and reports the
  result.

### `svc_unmask_then`
- **Signature:** `svc_unmask_then <scope> <unit> <action>` — for a masked unit,
  offers to `unmask` and then run the action.

### `svc_start_generic` / `svc_enable_generic` / `svc_disable_generic`
- **Signature:** `<fn> <scope> <unit>`
- **What they do:** the safety net around start/enable/disable — they detect
  `masked` (offer unmask) and `static`/`indirect`/`generated`/`alias`/`transient`
  (explain instead of failing cryptically) before calling `svc_run`.

### `service_actions`
- **Signature:** `service_actions <scope> <unit> <label>`
- **What it does:** the per-service action menu (start, stop, restart, enable,
  disable, view detailed status, refresh), showing the unit's live badge as the
  info line.

### `services_section`
- **Signature:** `services_section`
- **What it does:** the Services screen. Builds the list dynamically for the
  current filter (default `apps`), with XAMPP prepended for system scope,
  badges from the bulk maps, `f` to cycle filters, `r` to refresh, `n` to manage
  any unit by name, and a number/row to open `service_actions` (or
  `xampp_actions`).

---

## XAMPP (special case)

XAMPP can run outside systemd (its own `/opt/lampp` script), so it has a
dedicated path instead of the generic one.

### `xampp_present`
- **Signature:** `xampp_present` — returns `0` if `/opt/lampp/lampp` is executable.

### `xampp_running`
- **Signature:** `xampp_running` — returns `0` if XAMPP's daemons are up
  (`pgrep` of its `httpd`/`mysqld`), i.e. the real state, not systemd's.

### `xampp_can_autostart`
- **Signature:** `xampp_can_autostart` — returns `0` if the `xampp` unit is
  enable-able (its `is-enabled` is `enabled`/`disabled`, i.e. it has `[Install]`).

### `xampp_badges`
- **Signature:** `xampp_badges` — the badge using the real running state and the
  autostart state.

### `xampp_setup_unit`
- **Signature:** `xampp_setup_unit`
- **What it does:** writes `/etc/systemd/system/xampp.service` (a
  `Type=oneshot`/`RemainAfterExit` wrapper around `/opt/lampp/lampp start|stop`
  with an `[Install]` section) that shadows the static unit XAMPP ships, then
  `daemon-reload`s — so autostart can actually be enabled.

### `svc_run_xampp`
- **Signature:** `svc_run_xampp <lampp-action>` — runs `sudo /opt/lampp/lampp
  <action>` (start/stop/restart/…) and reports the result.

### `xampp_enable`
- **Signature:** `xampp_enable` — ensures an enable-able unit
  (`xampp_setup_unit` if needed), then `systemctl enable xampp`.

### `xampp_actions`
- **Signature:** `xampp_actions <label>`
- **What it does:** XAMPP's action menu — start/stop/restart via the lampp script,
  autostart via systemd, detailed status via `lampp status`.

---

## Main menu, language, navigation & startup

### `choose_language`
- **Signature:** `choose_language` — the language chooser (English / Spanish),
  saves it, used at first run and from the main menu.

### `choose_nav_firstrun`
- **Signature:** `choose_nav_firstrun` — first-run navigation-mode chooser
  (classic prompt, since the mode is not set yet); saves it.

### `choose_nav`
- **Signature:** `choose_nav` — the navigation-mode setting from Configuration
  (Arrows / Numbers), saved.

### `main_menu`
- **Signature:** `main_menu`
- **What it does:** the top-level menu loop (Install applications, Configuration,
  Services, System status, Install this toolkit as an app, Language). The header
  shows the detected package manager.

> **Startup** (at the end of the script): `load_lang`, `load_nav`, the first-run
> wizard (`choose_language` then `choose_nav_firstrun` when unset),
> `run_update_check auto`, then `main_menu`.
