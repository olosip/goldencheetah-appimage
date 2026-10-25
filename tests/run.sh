#!/usr/bin/env bash
# Test senza rete: curl, rpm e update-desktop-database sono sostituiti da finti comandi
# e l'AppImage è uno script finto. Verifica install, update, verifica sha256 e che
# uninstall lasci la home esattamente com'era.
set -euo pipefail

root="$(dirname "$(readlink -f "$0")")/.."
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

export HOME="$work/home"
unset XDG_DATA_HOME GC_DIR
stubs="$work/stubs"
srv="$work/server"
# Cartelle standard che esistono già in qualsiasi home, più i dati di GoldenCheetah
mkdir -p "$HOME/.local/share/applications" "$HOME/.local/share/icons" "$HOME/.local/bin" "$HOME/.goldencheetah" "$stubs" "$srv"
echo dati > "$HOME/.goldencheetah/atleta.ini"

make_appimage() {
    # make_appimage <file> <versione>: AppImage finta che sa estrarre desktop e icona
    cat > "$1" <<EOF
#!/bin/sh
# finta GoldenCheetah $2
if [ "\$1" = --appimage-extract ]; then
    mkdir -p squashfs-root
    printf '[Desktop Entry]\nIcon=gc\n' > squashfs-root/GoldenCheetah.desktop
    printf 'PNG-$2' > squashfs-root/gc.png
fi
EOF
    chmod +x "$1"
}

publish() {
    # publish <tag>: mette sul finto server la release <tag> come "latest"
    make_appimage "$srv/GoldenCheetah_$1_x64.AppImage" "$1"
    local sha size
    sha="$(sha256sum "$srv/GoldenCheetah_$1_x64.AppImage" | cut -d' ' -f1)"
    size="$(stat -c %s "$srv/GoldenCheetah_$1_x64.AppImage")"
    printf '{"tag_name":"%s","assets":[{"name":"GoldenCheetah_%s_x64.AppImage","size":%s,"digest":"sha256:%s","browser_download_url":"https://example/%s/GoldenCheetah_%s_x64.AppImage"}]}' \
        "$1" "$1" "$size" "$sha" "$1" "$1" > "$srv/latest.json"
    cp "$srv/latest.json" "$srv/tag-$1.json"
}

cat > "$stubs/curl" <<EOF
#!/usr/bin/env bash
out=""; url=""
while (( \$# )); do
    case "\$1" in -o) out="\$2"; shift 2 ;; -*) shift ;; *) url="\$1"; shift ;; esac
done
case "\$url" in
    */releases/latest) cat "$srv/latest.json" ;;
    */releases/tags/*) cat "$srv/tag-\${url##*/}.json" ;;
    https://example/*) cp "$srv/\${url##*/}" "\$out" ;;
    *) exit 22 ;;
esac
EOF
printf '#!/bin/sh\nexit 1\n' > "$stubs/rpm"
printf '#!/bin/sh\nexit 0\n' > "$stubs/update-desktop-database"
chmod +x "$stubs"/*
export PATH="$stubs:$PATH"

snapshot() { (cd "$HOME" && find . | sort); }
fail() { echo "FALLITO: $*" >&2; exit 1; }
gc="$HOME/.local/bin/gc-appimage"
app="$HOME/Applications/GoldenCheetah.AppImage"
desk="$HOME/.local/share/applications/goldencheetah.desktop"
icon="$HOME/.local/share/icons/goldencheetah.png"

before="$(snapshot)"
bash "$root/install.sh" >/dev/null
[[ -x "$gc" ]] || fail "script non installato"

# Installazione dell'ultima versione
publish v3.8
"$gc" install >/dev/null
[[ -x "$app" ]] || fail "AppImage non installata"
grep -qx "StartupWMClass=GoldenCheetah.AppImage" "$desk" || fail "StartupWMClass errato"
grep -qx "X-AppImage-Version=v3.8" "$desk" || fail "versione non registrata"
grep -qx "Exec=\"$app\"" "$desk" || fail "Exec errato"
[[ "$(cat "$icon")" == "PNG-v3.8" ]] || fail "icona non estratta"
[[ -e "$app.part" ]] && fail "file .part rimasto"
"$gc" install | grep -q "già installato" || fail "reinstalla senza motivo"
"$gc" status >/dev/null

# Aggiornamento a una nuova versione
publish v3.9
"$gc" update >/dev/null
grep -qx "X-AppImage-Version=v3.9" "$desk" || fail "update non eseguito"
grep -q "finta GoldenCheetah v3.9" "$app" || fail "AppImage non aggiornata"
"$gc" update | grep -q "già aggiornato" || fail "update ripetuto"

# Un file manomesso non deve mai sostituire quello installato
echo "manomesso" >> "$srv/GoldenCheetah_v3.9_x64.AppImage"
"$gc" install --force >/dev/null 2>&1 && fail "accettato un file con sha256 sbagliato"
grep -q "finta GoldenCheetah v3.9" "$app" || fail "AppImage installata rovinata"
[[ -e "$app.part" ]] && fail "file .part rimasto dopo l'errore"

# --from con un file locale valido, che poi viene eliminato su richiesta
publish v3.9
make_appimage "$HOME/scaricata.AppImage" v3.9
ASSUME_YES=1 "$gc" install --from "$HOME/scaricata.AppImage" >/dev/null
[[ -e "$HOME/scaricata.AppImage" ]] && fail "file originale non eliminato"

# Disinstallazione: home identica a prima, dati di GoldenCheetah intatti
"$gc" uninstall >/dev/null
after="$(snapshot)"
if [[ "$before" != "$after" ]]; then
    diff <(echo "$before") <(echo "$after") >&2 || true
    fail "la disinstallazione ha lasciato residui"
fi
[[ "$(cat "$HOME/.goldencheetah/atleta.ini")" == dati ]] || fail "dati dell'utente toccati"

echo "Tutti i test superati."
