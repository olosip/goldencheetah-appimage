#!/usr/bin/env bash
# Installa gc-fedora-appimage in ~/.local/bin (nessun permesso di root richiesto).
set -euo pipefail

src="$(dirname "$(readlink -f "$0")")/gc-fedora-appimage"
dest="$HOME/.local/bin/gc-fedora-appimage"

mkdir -p "$(dirname "$dest")"
install -m 0755 "$src" "$dest"
echo "Installato in $dest"

# Fino alla 0.1 lo script si chiamava gc-appimage
if [[ -f "$HOME/.local/bin/gc-appimage" ]]; then
    rm -f "$HOME/.local/bin/gc-appimage"
    echo "Rimosso il vecchio script $HOME/.local/bin/gc-appimage"
fi
echo "Poi esegui: gc-fedora-appimage install"
