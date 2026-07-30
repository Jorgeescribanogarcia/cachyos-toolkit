# Architecture

[← Index](README.md)

## The three scripts

| Script | Role | Runs as |
|---|---|---|
| `bin/cachyos-assistant` | Interactive, menu-driven UI. All the sections, navigation and catalogs live here. | normal user (asks `sudo` when needed) |
| `bin/cachyos-fix` | Non-interactive "fix engine". Discrete subcommands (`keyboard`, `wifi`, `repair-boot`…). The assistant calls it for system fixes. | normal user (uses `sudo` internally) |
| `install.sh` | Standalone bootstrap installer published in GitHub Releases. Clones the repo and registers the command + launcher. | normal user |

The assistant locates `cachyos-fix` next to itself (`SCRIPT_DIR`), falling back
to `PATH`. Both refuse to run as root.

## i18n (bilingual EN/ES)

Both scripts share the same design:

- Two associative arrays, `MSG_EN` and `MSG_ES`, map a **key** to a string.
- `t <key>` returns the string for the current `UI_LANG` (falling back to
  English, then to the key itself).
- The UI language is resolved by `load_lang` in this order: the `CACHYOS_LANG`
  environment variable → the saved file `~/.config/cachyos-toolkit/lang` → the
  system locale (`detect_system_lang`) → English.
- The assistant passes its language down to `cachyos-fix` through `CACHYOS_LANG`
  (see `run_fix`).

**Adding a UI string:** add the key to both `MSG_EN` and `MSG_ES`.

## Navigation (`menu_pick` / `menu_pick_multi`)

The assistant's menus are rendered by two reusable pickers:

- `menu_pick` — single choice. Stores the chosen key in the global
  `MENU_RESULT`; an optional info line is shown via `MENU_INFO`.
- `menu_pick_multi` — multiple choice (checkboxes), used by the install menus.
  Stores the outcome in `MULTI_ACTION` (`ok`/`empty`/`list`/`cancel`) and the
  selected indices in `MULTI_SEL`.

Both honor the **navigation mode** `NAV_MODE`:

- `arrows` — ↑/↓ (or `k`/`j`) move, Enter selects, the row's key selects it
  directly, `q`/Esc/← go back; in the multi picker Space toggles and `a`
  toggles all.
- `numbers` — the classic behavior: the list is printed and a typed key/line is
  read. This also works as a fallback for terminals where arrow keys misbehave.

`NAV_MODE` is resolved by `load_nav` (env `CACHYOS_NAV` → file
`~/.config/cachyos-toolkit/nav` → default `arrows`) and changed from
*Configuration › Navigation mode*.

## Settings storage

Everything user-level, under `${XDG_CONFIG_HOME:-~/.config}/cachyos-toolkit/`:

| File | Contents |
|---|---|
| `lang` | `en` or `es` |
| `nav`  | `arrows` or `numbers` |

## Startup

`cachyos-assistant` runs, in order: `load_lang`, `load_nav`, a first-run setup
wizard (asks language then navigation mode when neither is saved yet),
`run_update_check auto` (offers a `git pull` if the clone is behind), then
`main_menu`.

## Self-install and updates

The *Install this toolkit as an app* screen (main menu) and `install.sh` both
register a `cachyos-toolkit` command and a `.desktop` launcher pointing at the
clone (no copy is made), so `git pull` keeps everything current. On each launch
the assistant checks the git upstream and offers to update.
