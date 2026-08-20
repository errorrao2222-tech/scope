#!/usr/bin/env bash
# Second-pass rebrand: Quill -> Scope. Same protections as rebrand.sh.
set -euo pipefail
cd "$(dirname "$0")"
OLD=Quill; OLDL=quill; OLDU=QUILL
NEW=Scope; NEWL=scope; NEWU=SCOPE

is_excluded() {
  case "$1" in
    LICENSE|LICENSE.ungoogled_chromium|deps.ini|pruning.list|domain_substitution.list) return 0 ;;
    rebrand.sh|rebrand2.sh) return 0 ;;
  esac
  return 1
}

files=()
while IFS= read -r f; do
  is_excluded "$f" && continue
  [ -f "$f" ] || continue
  grep -Iq . "$f" 2>/dev/null || continue
  files+=("$f")
done < <(git ls-files)
echo ">> ${#files[@]} text files in scope"

OLD=$OLD OLDL=$OLDL OLDU=$OLDU NEW=$NEW NEWL=$NEWL NEWU=$NEWU \
perl -i -pe '
  s/\Q$ENV{OLDU}\E/$ENV{NEWU}/g;
  s/\Q$ENV{OLD}\E/$ENV{NEW}/g;
  s/\Q$ENV{OLDL}\E/$ENV{NEWL}/g;
' "${files[@]}"
echo ">> strings substituted"

ren() { [ -e "$1" ] && git mv "$1" "$2" && echo "   $1 -> $2"; }
ren utils/quill_version.py          utils/scope_version.py
ren resources/quill_resources.txt   resources/scope_resources.txt
ren patches/quill/core/add-quill-versioning.patch     patches/quill/core/add-scope-versioning.patch
ren patches/quill/core/ublock-quill-services.patch    patches/quill/core/ublock-scope-services.patch
ren patches/quill/settings/quill-noise-settings.patch patches/quill/settings/scope-noise-settings.patch
for n in color-mixers color-scheme logo-icons noise-page-info; do
  ren "patches/quill/ui/quill-$n.patch" "patches/quill/ui/scope-$n.patch"
done
ren patches/quill patches/scope
echo ">> done"
