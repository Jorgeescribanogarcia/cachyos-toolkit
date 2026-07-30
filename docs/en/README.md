# Advanced documentation (English)

[← Back to README](../../README.md) · [Español](../es/)

A per-function technical reference for CachyOS Toolkit. It documents every
function in the three scripts, grouped by category.

## Contents

- **[Architecture](architecture.md)** — the three scripts, how they fit
  together, the i18n system, the navigation system (`menu_pick` /
  `menu_pick_multi`) and where settings are stored.
- **[`cachyos-assistant`](assistant.md)** — the interactive assistant: every
  function, by category (i18n, style/helpers, navigation, install engine,
  application catalog, install section, configuration & fixes, services
  manager, maintenance, self-install & update, main menu & startup).
- **[`cachyos-fix`](fix.md)** — the fix engine: every subcommand and helper.
- **[`install.sh`](installer.md)** — the standalone release installer.

## Conventions

Each function is documented as:

- **Signature** — name and positional parameters (`$1`, `$2`…).
- **What it does** — a short description.
- **Reads / writes** — the globals, files or system state it touches.
- **Returns / output** — exit status and/or what it prints (many "chooser"
  functions return a value through a global variable, noted per function).
- **Notes** — edge cases and design decisions worth knowing.
