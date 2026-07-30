#!/usr/bin/env bash
#
# CachyOS Toolkit — installer / uninstaller
#
# Downloads the toolkit into ~/.local/share/cachyos-toolkit (a git clone, so it
# can update itself) and registers a 'cachyos-toolkit' command plus an
# application launcher (shows up in the app menu / KRunner). Uninstall removes
# all of it, including the downloaded folder.
#
# Run it as a normal user (never as root). Usage:
#   bash install.sh
#
set -uo pipefail

REPO_URL="https://github.com/Jorgeescribanogarcia/cachyos-toolkit.git"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
INSTALL_DIR="$DATA_DIR/cachyos-toolkit"
ASSISTANT="$INSTALL_DIR/bin/cachyos-assistant"
BIN_LINK="$HOME/.local/bin/cachyos-toolkit"
DESKTOP="$DATA_DIR/applications/cachyos-toolkit.desktop"

# ------------------------------ i18n ------------------------------
case "${LC_ALL:-}${LC_MESSAGES:-}${LANG:-}" in es*|*_ES*|*es_*) L=es ;; *) L=en ;; esac
declare -A EN ES

EN[title]="CachyOS Toolkit — installer"
EN[menu_install]="Install (download + command + app launcher)"
EN[menu_uninstall]="Uninstall (remove everything)"
EN[menu_exit]="Exit"
EN[choose]="Choose an option: "
EN[status_installed]="Status: installed at %s"
EN[status_not]="Status: not installed"
EN[err_root]="Do not run this as root. Use it as a normal user (it asks for sudo only to install git if missing)."
EN[need_git]="'git' is required to download the toolkit."
EN[installing_git]="Installing 'git' (official repos)…"
EN[git_fail]="Could not install 'git'. Install it and re-run."
EN[cloning]="Downloading the toolkit into %s…"
EN[updating]="Already downloaded; updating it (git pull)…"
EN[clone_fail]="Download failed (check your connection)."
EN[cmd_ok]="Command installed: %s"
EN[desktop_ok]="Launcher installed: %s"
EN[comment]="Install apps, apply fixes, manage services and system maintenance for CachyOS"
EN[path_warn]="Note: %s is not in your PATH; add it so 'cachyos-toolkit' works in the terminal."
EN[done]="Done. Search «CachyOS Toolkit» (Alt+Space) or run 'cachyos-toolkit'."
EN[uninstall_ask]="Remove the toolkit, its command and launcher?"
EN[uninstalling]="Removing…"
EN[uninstalled]="Uninstalled."
EN[not_installed]="It is not installed; nothing to remove."
EN[invalid]="Invalid option."
EN[goodbye]="See you!"
EN[yn]="y/N"

ES[title]="Instalador de CachyOS Toolkit"
ES[menu_install]="Instalar (descargar + comando + lanzador de app)"
ES[menu_uninstall]="Desinstalar (quitar todo)"
ES[menu_exit]="Salir"
ES[choose]="Elige una opción: "
ES[status_installed]="Estado: instalada en %s"
ES[status_not]="Estado: no instalada"
ES[err_root]="No lo ejecutes como root. Úsalo como usuario normal (solo pide sudo para instalar git si falta)."
ES[need_git]="Se necesita 'git' para descargar la herramienta."
ES[installing_git]="Instalando 'git' (repos oficiales)…"
ES[git_fail]="No se pudo instalar 'git'. Instálalo y vuelve a ejecutar."
ES[cloning]="Descargando la herramienta en %s…"
ES[updating]="Ya estaba descargada; la actualizo (git pull)…"
ES[clone_fail]="La descarga falló (revisa tu conexión)."
ES[cmd_ok]="Comando instalado: %s"
ES[desktop_ok]="Lanzador instalado: %s"
ES[comment]="Instala apps, aplica arreglos, gestiona servicios y mantenimiento del sistema en CachyOS"
ES[path_warn]="Aviso: %s no está en tu PATH; añádelo para que 'cachyos-toolkit' funcione en la terminal."
ES[done]="Hecho. Busca «CachyOS Toolkit» (Alt+Espacio) o ejecuta 'cachyos-toolkit'."
ES[uninstall_ask]="¿Quitar la herramienta, su comando y su lanzador?"
ES[uninstalling]="Eliminando…"
ES[uninstalled]="Desinstalada."
ES[not_installed]="No está instalada; nada que quitar."
ES[invalid]="Opción no válida."
ES[goodbye]="¡Hasta luego!"
ES[yn]="s/N"

t() { local -n _c="${L^^}"; printf '%s' "${_c[$1]}"; }

# ------------------------------ style -----------------------------
C_R=$'\033[0m'; C_B=$'\033[1m'; C_G=$'\033[1;32m'; C_Y=$'\033[1;33m'
C_RED=$'\033[1;31m'; C_C=$'\033[1;36m'; C_D=$'\033[2m'
log()  { printf '%s==>%s %s\n' "$C_C" "$C_R" "$*"; }
ok()   { printf '   %s✔%s %s\n' "$C_G" "$C_R" "$*"; }
warn() { printf '   %s!%s %s\n' "$C_Y" "$C_R" "$*"; }
err()  { printf '   %s✗%s %s\n' "$C_RED" "$C_R" "$*" >&2; }
confirm() { local r; read -rp "$(printf '%s%s [%s]: %s' "$C_B" "$1" "$(t yn)" "$C_R")" r; [[ "$r" =~ ^[sSyY]$ ]]; }

# ------------------------------ guards ----------------------------
if [ "$(id -u)" -eq 0 ]; then err "$(t err_root)"; exit 1; fi

is_installed() { [ -L "$BIN_LINK" ] || [ -e "$DESKTOP" ] || [ -d "$INSTALL_DIR" ]; }

# ------------------------------ install ---------------------------
do_install() {
  # 1) git
  if ! command -v git >/dev/null 2>&1; then
    warn "$(t need_git)"; log "$(t installing_git)"
    sudo pacman -S --needed --noconfirm git || { err "$(t git_fail)"; return 1; }
  fi

  # 2) download (clone) or update
  mkdir -p "$DATA_DIR"
  if [ -d "$INSTALL_DIR/.git" ]; then
    log "$(t updating)"
    git -C "$INSTALL_DIR" pull --ff-only || { err "$(t clone_fail)"; return 1; }
  else
    log "$(printf "$(t cloning)" "$INSTALL_DIR")"
    rm -rf -- "$INSTALL_DIR" 2>/dev/null
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" || { err "$(t clone_fail)"; return 1; }
  fi
  chmod +x "$INSTALL_DIR/bin/cachyos-assistant" "$INSTALL_DIR/bin/cachyos-fix" 2>/dev/null

  # 3) terminal command
  mkdir -p "$HOME/.local/bin"
  ln -sf "$ASSISTANT" "$BIN_LINK"
  ok "$(printf "$(t cmd_ok)" "$BIN_LINK")"

  # 4) desktop launcher (Terminal=true → the DE opens it in its terminal)
  mkdir -p "$DATA_DIR/applications"
  cat > "$DESKTOP" <<DSK
[Desktop Entry]
Type=Application
Name=CachyOS Toolkit
GenericName=System configuration assistant
Comment=$(t comment)
Exec=$ASSISTANT
Icon=applications-system
Terminal=true
Categories=System;
Keywords=cachyos;toolkit;assistant;config;fixes;services;
DSK
  ok "$(printf "$(t desktop_ok)" "$DESKTOP")"
  command -v update-desktop-database >/dev/null 2>&1 \
    && update-desktop-database "$DATA_DIR/applications" 2>/dev/null

  # 5) PATH hint
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) : ;;
    *) warn "$(printf "$(t path_warn)" "$HOME/.local/bin")" ;;
  esac
  ok "$(t done)"
}

# ------------------------------ uninstall -------------------------
do_uninstall() {
  if ! is_installed; then warn "$(t not_installed)"; return 0; fi
  confirm "$(t uninstall_ask)" || return 0
  log "$(t uninstalling)"
  rm -f "$BIN_LINK" "$DESKTOP"
  [ -n "$INSTALL_DIR" ] && [ -d "$INSTALL_DIR" ] && rm -rf -- "$INSTALL_DIR"
  command -v update-desktop-database >/dev/null 2>&1 \
    && update-desktop-database "$DATA_DIR/applications" 2>/dev/null
  ok "$(t uninstalled)"
}

# ------------------------------ menu ------------------------------
while true; do
  clear 2>/dev/null || true
  printf '%s%s%s\n' "$C_C$C_B" "$(t title)" "$C_R"
  if is_installed; then
    printf '%s%s%s\n\n' "$C_D" "$(printf "$(t status_installed)" "$INSTALL_DIR")" "$C_R"
  else
    printf '%s%s%s\n\n' "$C_D" "$(t status_not)" "$C_R"
  fi
  printf '  %s1)%s %s\n'   "$C_B" "$C_R" "$(t menu_install)"
  printf '  %s2)%s %s\n'   "$C_B" "$C_R" "$(t menu_uninstall)"
  printf '\n  %s0)%s %s\n\n' "$C_B" "$C_R" "$(t menu_exit)"
  read -rp "$(t choose)" op
  case "$op" in
    1) do_install ;;
    2) do_uninstall ;;
    0|q|Q|"") printf '\n%s\n' "$(t goodbye)"; exit 0 ;;
    *) warn "$(t invalid)" ;;
  esac
  printf '\n%s' "${C_D}Enter…${C_R}"; read -r _
done
