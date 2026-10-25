#!/usr/bin/env bash
# Installa gc-appimage in ~/.local/bin (nessun permesso di root richiesto).
set -euo pipefail

src="$(dirname "$(readlink -f "$0")")/gc-appimage"
dest="$HOME/.local/bin/gc-appimage"

mkdir -p "$(dirname "$dest")"
install -m 0755 "$src" "$dest"
echo "Installato in $dest"
echo "Poi esegui: gc-appimage install"
