#!/usr/bin/env bash
# Fast project verification. Run by the habii-core Stop hook before Claude finishes.
# Exit 0 = green. Any other exit returns the error to Claude to fix.
# Static site: checks asset refs, inline DC script syntax and basic structure.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"
html=index.html
fail=0

# 1. Every ./assets/ reference points to an existing file
while IFS= read -r ref; do
  [ -z "$ref" ] && continue
  if [ ! -f "$ref" ]; then
    echo "verify: missing asset referenced in $html: $ref" >&2
    fail=1
  fi
done < <(grep -oE '\./assets/[^"'"'"' )]+' "$html" | sort -u)

# 2. Structure: exactly one <x-dc>, one </x-dc>, one data-dc-script
for pat in '<x-dc>' '</x-dc>' 'data-dc-script'; do
  n=$(grep -c -- "$pat" "$html" || true)
  if [ "$n" -ne 1 ]; then
    echo "verify: expected exactly 1 occurrence of '$pat' in $html, found $n" >&2
    fail=1
  fi
done

# 3. Inline DC script parses as JavaScript
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
tmp="$tmpdir/dc-script.js"
awk '/<script[^>]*data-dc-script/{f=1; next} f && /<\/script>/{f=0} f' "$html" > "$tmp"
if [ ! -s "$tmp" ]; then
  echo "verify: could not extract data-dc-script block from $html" >&2
  fail=1
elif ! node --check "$tmp"; then
  echo "verify: syntax error in data-dc-script block of $html" >&2
  fail=1
fi

[ "$fail" -eq 0 ] || exit 1
echo "verify: OK"
