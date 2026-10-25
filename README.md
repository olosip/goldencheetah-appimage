# goldencheetah-appimage

GoldenCheetah ufficiale (AppImage) su Fedora, **con il collegamento a Strava funzionante**,
il collegamento nel menu di GNOME e l'icona giusta anche nella dash.

## Il problema

Con il pacchetto Fedora (`sudo dnf install GoldenCheetah`, versione 3.8 su Fedora 44), collegando
Strava dalla configurazione degli account cloud compare l'errore:

> L'host richiede autenticazione (204)

Non dipende dal vostro account. GoldenCheetah, per parlare con Strava, ha bisogno di una chiave
segreta (*client secret*) che va inserita **al momento della compilazione**. Il pacchetto Fedora è
compilato senza: dentro il programma c'è ancora il segnaposto.

```bash
strings /usr/bin/GoldenCheetah | grep __GC_STRAVA
# &client_secret=__GC_STRAVA_CLIENT_SECRET__
```

GoldenCheetah manda a Strava una chiave fasulla e Strava la rifiuta. Riprovare non serve.

## La soluzione

L'**AppImage ufficiale** pubblicata dagli sviluppatori
([release su GitHub](https://github.com/GoldenCheetah/GoldenCheetah/releases)) contiene la chiave
giusta, e con lei Strava funziona. Usa la stessa cartella dati `~/.goldencheetah` del pacchetto
Fedora, quindi atleti e attività restano.

Installarla a mano lascia però qualche spigolo: niente voce nel menu e, anche dopo averla creata,
nella dash compare un rombo blu al posto del ghepardo. GNOME riconosce le finestre dal loro
`WM_CLASS`, e quello dell'AppImage è **il nome del file** (es. `GoldenCheetah_v3.8_x64.AppImage`),
che cambia a ogni versione.

`gc-appimage` sistema tutto:

- scarica l'ultima AppImage stabile e ne **verifica lo sha256** con quello pubblicato su GitHub;
- la salva sempre come `~/Applications/GoldenCheetah.AppImage`, così il `WM_CLASS` non cambia e
  l'icona nella dash resta giusta anche dopo gli aggiornamenti;
- estrae l'icona originale dall'AppImage e crea il collegamento nel menu;
- si aggiorna con un comando e si disinstalla senza lasciare residui.

## Installazione

```bash
sudo dnf install fuse-libs            # FUSE 2, richiesto dalle AppImage
sudo dnf remove GoldenCheetah         # facoltativo: il pacchetto Fedora senza Strava
git clone https://github.com/olosip/goldencheetah-appimage.git
cd goldencheetah-appimage
./install.sh
gc-appimage install
```

Se avete già scaricato l'AppImage, evitate di riscaricarla (viene comunque verificata):

```bash
gc-appimage install --from ~/Scaricati/GoldenCheetah_v3.8_x64.AppImage
```

Poi aprite GoldenCheetah dal menu e rifate il collegamento a Strava.

## Comandi

| Comando | Cosa fa |
|---|---|
| `gc-appimage install` | scarica, verifica e installa l'ultima versione stabile |
| `gc-appimage install --from FILE` | usa un'AppImage già scaricata (verificata con lo sha256) |
| `gc-appimage install --version TAG` | installa una versione precisa, es. `v3.8` |
| `gc-appimage update` | installa la nuova versione stabile, se c'è |
| `gc-appimage status` | versione installata, ultima disponibile, requisiti |
| `gc-appimage uninstall` | rimuove AppImage, collegamento e icona |

La cartella dell'AppImage si cambia con `GC_DIR` (predefinita: `~/Applications`).

## Disinstallazione senza residui

```bash
gc-appimage uninstall
```

Rimuove AppImage, collegamento, icona, la cartella `~/Applications` se resta vuota e lo script
stesso. **I dati in `~/.goldencheetah` non vengono toccati**: se volete eliminarli, fatelo a mano.

## Note

- Nel terminale può comparire `Could not find the Qt platform plugin "wayland"`: l'AppImage usa
  XWayland, funziona normalmente.
- Al primo avvio la 3.8 chiede se scaricare le icone degli sport: è indipendente da Strava.

## Test

```bash
bash tests/run.sh
```

I test non usano la rete: GitHub e l'AppImage sono simulati in una home temporanea. Verificano
installazione, aggiornamento, rifiuto di un file con sha256 sbagliato e che dopo `uninstall` la
home sia identica a prima, con i dati di GoldenCheetah intatti.

## Licenza

[MIT](LICENSE)
