# `install.sh` — function reference

[← Index](README.md)

The standalone bootstrap installer published in GitHub Releases. It clones the
toolkit into `~/.local/share/cachyos-toolkit` and registers a `cachyos-toolkit`
command plus a `.desktop` launcher. It is bilingual (EN/ES, from the locale),
refuses to run as root, and presents a small **Install / Uninstall** menu.

### Key paths

| Variable | Value |
|---|---|
| `INSTALL_DIR` | `${XDG_DATA_HOME:-~/.local/share}/cachyos-toolkit` (the git clone) |
| `ASSISTANT`   | `$INSTALL_DIR/bin/cachyos-assistant` |
| `BIN_LINK`    | `~/.local/bin/cachyos-toolkit` (symlink → `$ASSISTANT`) |
| `DESKTOP`     | `…/applications/cachyos-toolkit.desktop` |

---

### `t`
- **Signature:** `t <key>`
- **What it does:** returns the localized string from the `EN`/`ES` associative
  arrays for the detected locale.

### `log` / `ok` / `warn` / `err`
- **Signature:** `log|ok|warn|err <message>`
- **What they do:** colored status lines (same convention as the other scripts;
  `err` goes to stderr).

### `confirm`
- **Signature:** `confirm <question>`
- **What it does:** prompts with a `[y/N]` (`[s/N]`) suffix.
- **Returns:** `0` if the answer is yes (`y`/`s`), non-zero otherwise.

### `is_installed`
- **Signature:** `is_installed`
- **What it does:** reports whether the toolkit is installed.
- **Returns:** `0` if the command symlink, the `.desktop` **or** the clone folder
  exists.

### `do_install`
- **Signature:** `do_install`
- **What it does:** (1) ensures `git` is available (offers `sudo pacman -S git`);
  (2) clones the repo into `INSTALL_DIR` with `git clone --depth 1`, or
  `git pull` if it is already there; (3) creates the `cachyos-toolkit` symlink in
  `~/.local/bin`; (4) writes the `.desktop` launcher (`Terminal=true`,
  `Exec=$ASSISTANT`, `Categories=System;`); (5) runs `update-desktop-database`;
  (6) warns if `~/.local/bin` is not in `PATH`.
- **Returns:** non-zero on a failed git/clone step.

### `do_uninstall`
- **Signature:** `do_uninstall`
- **What it does:** if installed, asks for confirmation and removes the command
  symlink, the `.desktop`, and the whole `INSTALL_DIR` clone, then refreshes the
  desktop database.
- **Notes:** guards the removal (`INSTALL_DIR` non-empty and a directory).

### Menu loop
- The script's body is a `while` loop that redraws the **Install / Uninstall /
  Exit** menu (with the current install status) and dispatches to `do_install` /
  `do_uninstall`.
