<div align="center">
    <img src="resources/branding/app_icon/raw.png"
        title="Quill" alt="Quill logo" width="120" />
    <h1>Quill</h1>
    <p>
        The browser built for the trenches.
        <br>
        Privacy-first, ad-blocking, no telemetry. Made for memecoin traders.
    </p>
</div>

## Status

> [!WARNING]
> Quill is pre-release and has never been built or published. The rebrand is
> complete; the items under [Before you ship](#before-you-ship) are not.

## What Quill is

Quill is a white-label fork of [Helium](https://github.com/imputnet/helium) by
[imputnet](https://github.com/imputnet). Helium is itself based on
[ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium),
which is based on [Chromium](https://www.chromium.org/).

This repository holds the shared Chromium patches, branding resources, and
tooling. It is **not** a Chromium checkout — the build downloads Chromium's
official source tarball and applies the 321 patches in [`patches/`](patches/)
on top of it.

Everything Quill inherits from Helium is intact: built-in uBlock Origin as a
bundled component, canvas/audio/hardware-concurrency fingerprint noise, split
ClientHello, DNS-over-HTTPS, vertical tabs and zen mode, and end-to-end
encrypted sync. See [`patches/quill/`](patches/quill/) for the full set.

## Building

Quill has no platform packaging repo of its own yet. Building requires
rebranding one of Helium's platform repos to consume this one:

| Platform | Upstream packaging repo |
| --- | --- |
| Windows | [imputnet/helium-windows](https://github.com/imputnet/helium-windows) |
| macOS | [imputnet/helium-macos](https://github.com/imputnet/helium-macos) |
| Linux | [imputnet/helium-linux](https://github.com/imputnet/helium-linux) |

A full Chromium build needs roughly 100 GB of free disk and several hours.
On Windows you also need Visual Studio with Chromium's component set, LLVM,
7-Zip, Git, Python 3.8+ (`httplib2==0.22.0` and `Pillow`), and the
`MAX_PATH` 260-character limit lifted.

## Before you ship

The rebrand is done, but these are deliberate open decisions, not oversights:

- **Icons and logo.** [`resources/branding/`](resources/branding/) still holds
  Helium's artwork. Shipping it publicly would be using imputnet's branding.
  Replace before any public release.
- **Outbound endpoints.** Crash reporting, update checks, and the services
  backend point at `*.quill.invalid`, which never resolves — so Quill does not
  phone home to imputnet, and equally has no crash reporting or auto-updates.
  Point them at real infrastructure or leave them dead.
- **Issue tracker.** The in-app "report a bug" link points at
  `github.com/YOUR-ORG/quill`. Update it.
- **uBlock filter lists.** Still fetched from
  `raw.githubusercontent.com/imputnet/helium-services`. They work, but you are
  using imputnet's bandwidth. Mirror them.
- **Search engine data and onboarding assets.** [`deps.ini`](deps.ini) still
  downloads these from imputnet's releases. Required for the build to work.

Re-run [`rebrand.sh`](rebrand.sh) after `git checkout .` to rebrand under a
different name; the configuration block at the top is the only thing to edit.

## License

Quill is licensed under **GPL-3.0**, inherited from Helium. See [LICENSE](LICENSE).

This means if you distribute Quill — including as a binary — you must make the
complete corresponding source available under GPL-3.0, retain the copyright
notices, and keep the license intact. Content imported from other projects
retains its original license; unmodified ungoogled-chromium code remains under
their [BSD 3-Clause license](LICENSE.ungoogled_chromium).

Quill is not affiliated with or endorsed by imputnet, Helium, ungoogled-chromium,
or Google.

## Credits

- [The Chromium Project](https://www.chromium.org/) — the engine underneath everything
- [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium) — de-Googling patchset
- [Helium](https://github.com/imputnet/helium) — the browser Quill is forked from
- Patches also imported from [Inox](https://github.com/gcarq/inox-patchset),
  [Debian](https://tracker.debian.org/pkg/chromium-browser),
  [Bromite](https://github.com/bromite/bromite),
  [Iridium](https://iridiumbrowser.de/), and [Brave](https://github.com/brave/brave-core).
  All patches are sorted by vendor in [`patches/`](patches/).
