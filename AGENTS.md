# Quill AI Agent Guidelines

Quill is a white-label fork of [Helium](https://github.com/imputnet/helium).
This file replaces the upstream AGENTS.md, which stated imputnet's policy for
*their* repository. That policy still binds anything sent upstream.

## Hard rules

- **Never open issues or pull requests against `imputnet/*` repositories.**
  Helium's maintainers prohibit AI-assisted contributions and ban contributors
  who submit them. Quill's changes stay in Quill.
- **Never strip GPL copyright notices.** Lines of the form
  `Copyright <year> The Helium Authors` must survive every rebrand and refactor.
  `rebrand.sh` protects them deliberately — do not "clean them up".
- **Never rename these**, they are load-bearing:
  - `helium_onboarding` — the extraction path fixed by `deps.ini`
  - any `imputnet/...` URL in `deps.ini` — build-time downloads
  - `patches/quill/core/update-credits.patch` — upstream attribution

## Working in this repo

- Code changes are quilt patches applied on top of Chromium. Do not hand-edit
  files in `patches/` unless you know what you are doing — change the Chromium
  source tree and refresh the affected patch.
- Keep patch ordering and vendor grouping intact. `patches/series` must list
  every patch on disk, and every patch on disk must be listed.
- Line endings are LF. `.gitattributes` sets `* -text` and the repo sets
  `core.autocrlf=false` — CRLF breaks patch application.
