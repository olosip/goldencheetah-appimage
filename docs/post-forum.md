# Forum post (Fedora Discussion, Reddit r/Fedora, GoldenCheetah forum)

**Title:** GoldenCheetah on Fedora: Strava fails with "Host requires authentication (204)" – why, and a fix

If you installed GoldenCheetah with `dnf` on Fedora 44 and linking Strava from the cloud accounts
fails with **"Host requires authentication (204)"**, retrying or signing in again won't help.

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
tool, [gc-fedora-appimage](https://github.com/olosip/goldencheetah-fedora-appimage), that handles it:

```bash
sudo dnf install fuse-libs
git clone https://github.com/olosip/goldencheetah-fedora-appimage.git && cd goldencheetah-fedora-appimage
./install.sh
gc-fedora-appimage install    # downloads and verifies the sha256 against GitHub
```

It creates the menu entry with the original icon (correct in the dash too), updates with
`gc-fedora-appimage update` and uninstalls cleanly without touching your data. The tool's messages
are in Italian for now; the README is in English.

It would help to report the packaging issue to the Fedora maintainers on
[Bugzilla](https://bugzilla.redhat.com/enter_bug.cgi?product=Fedora&component=GoldenCheetah) – I
couldn't find an existing report.
