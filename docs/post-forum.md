# Post per forum (Fedora Discussion, Reddit r/Fedora, forum di GoldenCheetah, forum italiani)

---

## 🇮🇹 Versione italiana

**Titolo:** GoldenCheetah su Fedora: Strava dà "L'host richiede autenticazione (204)"? Ecco perché

Avete installato GoldenCheetah con `dnf` su Fedora 44 e, collegando Strava dagli account cloud,
ottenete l'errore **"L'host richiede autenticazione (204)"**? Riprovare o rifare il login non serve.

**La causa:** GoldenCheetah ha bisogno di una chiave segreta di Strava (*client secret*) inserita
al momento della compilazione. Il pacchetto Fedora è compilato senza, e nel programma è rimasto il
segnaposto. Potete verificarlo così:

```bash
strings /usr/bin/GoldenCheetah | grep __GC_STRAVA
```

Se compare `client_secret=__GC_STRAVA_CLIENT_SECRET__`, GoldenCheetah sta mandando a Strava una
chiave fasulla.

**La soluzione:** usare l'**AppImage ufficiale** degli sviluppatori
([release GitHub](https://github.com/GoldenCheetah/GoldenCheetah/releases)), che contiene la chiave
giusta. Usa la stessa cartella `~/.goldencheetah`, quindi atleti e attività restano. Serve
`sudo dnf install fuse-libs`.

Installandola a mano però manca la voce nel menu e nella dash compare un rombo blu invece del
ghepardo: GNOME riconosce la finestra dal nome del file, che cambia a ogni versione. Per evitare
tutto questo ho scritto un piccolo strumento,
[gc-appimage](https://github.com/olosip/goldencheetah-appimage):

```bash
sudo dnf install fuse-libs
git clone https://github.com/olosip/goldencheetah-appimage.git && cd goldencheetah-appimage
./install.sh
gc-appimage install          # scarica e verifica lo sha256 con GitHub
```

Crea il collegamento nel menu con l'icona originale (giusta anche nella dash), si aggiorna con
`gc-appimage update` e si disinstalla senza residui, senza toccare i vostri dati.

Sarebbe utile segnalare il problema del pacchetto ai manutentori Fedora su
[Bugzilla](https://bugzilla.redhat.com/enter_bug.cgi?product=Fedora&component=GoldenCheetah):
non ho trovato segnalazioni esistenti.

---

## 🇬🇧 English version

**Title:** GoldenCheetah on Fedora: Strava fails with "Host requires authentication (204)" – why, and a fix

If you installed GoldenCheetah with `dnf` on Fedora 44 and linking Strava from the cloud accounts
fails with **"Host requires authentication (204)"**, retrying won't help.

**Cause:** GoldenCheetah needs a Strava *client secret* injected at build time. The Fedora package
is built without it, so the binary still contains the placeholder:

```bash
strings /usr/bin/GoldenCheetah | grep __GC_STRAVA
```

If you see `client_secret=__GC_STRAVA_CLIENT_SECRET__`, GoldenCheetah is sending Strava a fake key.

**Fix:** use the **official AppImage** from the developers
([GitHub releases](https://github.com/GoldenCheetah/GoldenCheetah/releases)), which includes the
real key. It uses the same `~/.goldencheetah` folder, so your athletes and activities are kept.
It needs `sudo dnf install fuse-libs`.

Installed by hand, though, it has no menu entry, and the dash shows a generic blue icon: GNOME
matches the window by the file name (`WM_CLASS`), which changes with every version. I wrote a small
tool, [gc-appimage](https://github.com/olosip/goldencheetah-appimage), that handles it:

```bash
sudo dnf install fuse-libs
git clone https://github.com/olosip/goldencheetah-appimage.git && cd goldencheetah-appimage
./install.sh
gc-appimage install          # downloads and verifies the sha256 against GitHub
```

It creates the menu entry with the original icon (correct in the dash too), updates with
`gc-appimage update` and uninstalls cleanly without touching your data. Messages and README are in
Italian for now.

It would help to report the packaging issue to the Fedora maintainers on
[Bugzilla](https://bugzilla.redhat.com/enter_bug.cgi?product=Fedora&component=GoldenCheetah) – I
couldn't find an existing report.
