#!/usr/bin/env bash
# Verify all _redirects destinations exist in staged docs/.
# Usage: bash scripts/test-redirects.sh [docs-dir]
set -euo pipefail
DOCS_DIR="${1:-docs}"
REDIRECTS="_redirects"
fail=0
count=0
while IFS= read -r line; do
  # skip blanks and comments; format: /from /to 301
  case "$line" in ''|'#'*) continue;; esac
  dest=$(printf '%s' "$line" | awk '{print $2}')
  [ -z "$dest" ] && continue
  page="${dest#/}"
  count=$((count + 1))
  if [ ! -f "$DOCS_DIR/$page" ]; then
    echo "MISSING: $dest (expected $DOCS_DIR/$page)"
    fail=$((fail + 1))
  fi
done < "$REDIRECTS"
echo "Checked $count redirects against $DOCS_DIR/, missing: $fail"
[ "$count" -eq 2 ] || { echo "Expected 2 redirect rules, found $count"; exit 1; }
exit "$fail"
