#!/usr/bin/env bash
# rebrand.sh - white-label this Chromium fork under a new product name.
#
# Re-runnable and parameterized: change the config block, `git checkout .`,
# then run again to rebrand under a different name.
#
# Deliberately does NOT touch:
#   - GPL copyright notices ("Copyright YYYY The Helium Authors")
#   - upstream attribution in the credits page
#   - build-time download URLs in deps.ini (they must keep resolving)
#   - the helium_onboarding build path (tied to deps.ini output_path)
set -euo pipefail

# ---------------------------------------------------------------- config ----
NEW_NAME="Quill"                 # replaces Helium   (user-visible product name)
NEW_LOWER="quill"                # replaces helium   (URL scheme, identifiers)
NEW_UPPER="QUILL"                # replaces HELIUM   (macros, version keys)
COMPANY="The Quill Authors"
BUNDLE_ID="com.quill.browser"
MAC_TEAM_ID=""                   # imputnet's team ID must not be reused

# Outbound endpoints. Default to RFC-2606 .invalid (never resolves) so a fresh
# fork does not silently phone home to imputnet's infrastructure.
CRASH_URL="https://crash.${NEW_LOWER}.invalid/crash"
UPDATES_URL="https://updates.${NEW_LOWER}.invalid/"
SERVICES_URL="https://services.${NEW_LOWER}.invalid"
ISSUES_URL="https://github.com/YOUR-ORG/${NEW_LOWER}/issues/new"
# -----------------------------------------------------------------------------

cd "$(dirname "$0")"

# Files kept verbatim, with the reason.
is_excluded() {
  case "$1" in
    LICENSE|LICENSE.ungoogled_chromium) return 0 ;;  # never rewrite licenses
    deps.ini)                           return 0 ;;  # build download URLs
    pruning.list|domain_substitution.list) return 0 ;;  # chromium tree paths
    devutils/i18n_generate.py)          return 0 ;;  # upstream repo URLs
    patches/helium/core/update-credits.patch) return 0 ;;  # upstream attribution
    .github/*)                          return 0 ;;  # upstream CI + secrets
    rebrand.sh)                         return 0 ;;
  esac
  return 1
}

echo ">> collecting files"
files=()
while IFS= read -r f; do
  is_excluded "$f" && continue
  [ -f "$f" ] || continue
  grep -Iq . "$f" 2>/dev/null || continue   # skip binaries
  files+=("$f")
done < <(git ls-files)
echo "   ${#files[@]} text files in scope"

echo ">> substituting strings"
NEW_NAME="$NEW_NAME" NEW_LOWER="$NEW_LOWER" NEW_UPPER="$NEW_UPPER" \
perl -i -pe '
  # --- protect (sentinels are restored at the end of this same pass) ---
  # GPL copyright notices: keyed on a literal 4-digit year, which the
  # BRANDING company/COPYRIGHT lines do not have.
  s/(Copyright\s*(?:\([cC]\)\s*)?\d{4},?\s+The )Helium(\s+Authors)/${1}\@\@KEEP\@\@${2}/g;
  # build path, fixed by deps.ini output_path
  s/helium_onboarding/\@\@ONB\@\@/g;
  # every upstream repo/asset URL under imputnet/
  s{imputnet/helium([A-Za-z0-9._-]*)}{\@\@IMPUT$1\@\@}g;
  # uBlock filter lists served from that org
  s/helium-(annoyances|unbreak)/\@\@FILT$1\@\@/g;

  # --- main substitution ---
  s/HELIUM/$ENV{NEW_UPPER}/g;
  s/Helium/$ENV{NEW_NAME}/g;
  s/helium/$ENV{NEW_LOWER}/g;

  # --- restore ---
  s/\@\@KEEP\@\@/Helium/g;
  s/\@\@ONB\@\@/helium_onboarding/g;
  s{\@\@IMPUT([A-Za-z0-9._-]*)\@\@}{imputnet/helium$1}g;
  s/\@\@FILT(annoyances|unbreak)\@\@/helium-$1/g;
' "${files[@]}"

echo ">> applying targeted fixes"
B=patches/helium/core/change-chromium-branding.patch
perl -i -pe "
  s/^\+MAC_BUNDLE_ID=.*/+MAC_BUNDLE_ID=$BUNDLE_ID/;
  s/^\+MAC_TEAM_ID=.*/+MAC_TEAM_ID=$MAC_TEAM_ID/;
  s/^\+COMPANY_FULLNAME=.*/+COMPANY_FULLNAME=$COMPANY/;
  s/^\+COMPANY_SHORTNAME=.*/+COMPANY_SHORTNAME=$COMPANY/;
" "$B"

# Point outbound endpoints away from imputnet's servers.
for f in "${files[@]}"; do
  perl -i -pe "
    s{https://crash\.${NEW_LOWER}\.computer/crash}{$CRASH_URL}g;
    s{https://updates\.${NEW_LOWER}\.computer/}{$UPDATES_URL}g;
    s{https://services\.${NEW_LOWER}\.imput\.net}{$SERVICES_URL}g;
    s{https://github\.com/imputnet/helium/issues/new}{$ISSUES_URL}g;
  " "$f"
done

echo ">> renaming paths"
ren() { [ -e "$1" ] && git mv "$1" "$2" && echo "   $1 -> $2"; }
ren resources/helium_resources.txt "resources/${NEW_LOWER}_resources.txt"
ren utils/helium_version.py        "utils/${NEW_LOWER}_version.py"
for p in patches/helium/core/add-helium-versioning.patch \
         patches/helium/core/ublock-helium-services.patch \
         patches/helium/settings/helium-noise-settings.patch \
         patches/helium/ui/helium-color-mixers.patch \
         patches/helium/ui/helium-color-scheme.patch \
         patches/helium/ui/helium-logo-icons.patch \
         patches/helium/ui/helium-noise-page-info.patch; do
  ren "$p" "$(echo "$p" | sed "s|/helium-|/${NEW_LOWER}-|; s|add-helium-|add-${NEW_LOWER}-|; s|ublock-helium-|ublock-${NEW_LOWER}-|")"
done
ren patches/helium "patches/${NEW_LOWER}"

echo ">> done"
