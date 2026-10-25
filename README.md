# goldencheetah-fedora-appimage

The official GoldenCheetah AppImage on Fedora, **with a working Strava connection**, a GNOME menu
entry and the right icon in the dash too.

## The problem

With the Fedora package (`sudo dnf install GoldenCheetah`, version 3.8 on Fedora 44), linking
Strava from the cloud accounts settings fails with:

> Host requires authentication (204)

It's not your account. To talk to Strava, GoldenCheetah needs a secret key (*client secret*) that
is injected **at build time**. The Fedora package is built without it, so the binary still contains
the placeholder:

```bash
strings /usr/bin/GoldenCheetah | grep __GC_STRAVA
# &client_secret=__GC_STRAVA_CLIENT_SECRET__
```

GoldenCheetah sends Strava a fake key and Strava rejects it. Retrying won't help.

## The fix

The **official AppImage** published by the developers
([GitHub releases](https://github.com/GoldenCheetah/GoldenCheetah/releases)) includes the real
key, and Strava works with it. It uses the same `~/.goldencheetah` data folder as the Fedora
package, so your athletes and activities are kept.

Installing it by hand has a few rough edges, though: no menu entry and, even after creating one, a
generic blue icon in the dash instead of the cheetah. GNOME matches windows by their `WM_CLASS`,
and the AppImage's one is **the file name** (e.g. `GoldenCheetah_v3.8_x64.AppImage`), which changes
with every version.

`gc-fedora-appimage` takes care of all of it:

- downloads the latest stable AppImage and **verifies its sha256** against the one published on
  GitHub;
- always saves it as `~/Applications/GoldenCheetah.AppImage`, so the `WM_CLASS` never changes and
  the dash icon stays right across updates;
- extracts the original icon from the AppImage and creates the menu entry;
- updates with one command and uninstalls without leaving anything behind.

## Installation

```bash
sudo dnf install fuse-libs            # FUSE 2, required by AppImages
sudo dnf remove GoldenCheetah         # optional: the Fedora package without Strava
git clone https://github.com/olosip/goldencheetah-fedora-appimage.git
cd goldencheetah-fedora-appimage
./install.sh
gc-fedora-appimage install
```

If you already downloaded the AppImage, skip the download (it is verified anyway):

```bash
gc-fedora-appimage install --from ~/Downloads/GoldenCheetah_v3.8_x64.AppImage
```

Then open GoldenCheetah from the menu and link Strava again.

## Commands

| Command | What it does |
|---|---|
| `gc-fedora-appimage install` | downloads, verifies and installs the latest stable version |
| `gc-fedora-appimage install --from FILE` | uses an AppImage you already downloaded (sha256-verified) |
| `gc-fedora-appimage install --version TAG` | installs a specific version, e.g. `v3.8` |
| `gc-fedora-appimage update` | installs the new stable version, if there is one |
| `gc-fedora-appimage status` | installed version, latest available, requirements |
| `gc-fedora-appimage uninstall` | removes the AppImage, menu entry and icon |

The AppImage folder can be changed with `GC_DIR` (default: `~/Applications`). The tool's messages
are in Italian for now.

## Clean uninstall

```bash
gc-fedora-appimage uninstall
```

Removes the AppImage, menu entry, icon, `~/Applications` if left empty, and the script itself.
**Your data in `~/.goldencheetah` is not touched**: delete it by hand if you want to.

## Upgrading from gc-appimage

Up to version 0.1 the script was called `gc-appimage`. Running `./install.sh` from this version
removes the old script; the AppImage and menu entry stay as they are.

## Notes

- The terminal may show `Could not find the Qt platform plugin "wayland"`: the AppImage runs under
  XWayland and works normally.
- On first launch 3.8 asks whether to download the sport icons: it's unrelated to Strava.

## Tests

```bash
bash tests/run.sh
```

The tests don't use the network: GitHub and the AppImage are simulated in a temporary home. They
check installation, update, rejection of a file with the wrong sha256, and that after `uninstall`
the home is exactly as before, with GoldenCheetah's data intact.

## License

[MIT](LICENSE)
