#!/usr/bin/env bash
# Core readiness by default. Module mode requires the missing original artifacts.
set -euo pipefail
source "$(dirname "$0")/common.sh"
case "${1:-}" in
  '') exec bash scripts/smoke.sh ;;
  --modules)
    missing=0
    for n in $(seq -w 1 20); do
      for file in "exploits/$n/run.sh" "tests/$n/test.sh" "exploits/$n/README.md" "modules/$n/notes.md"; do
        if [ ! -s "$file" ]; then echo "MISSING $file"; missing=1; fi
      done
      git rev-parse --verify -q "refs/heads/fix/$n" >/dev/null || { echo "MISSING local branch fix/$n"; missing=1; }
    done
    [ "$missing" = 0 ] || { echo 'Cannot validate twenty modules: original artifacts are absent.' >&2; exit 1; }
    [ "$(git branch --show-current)" = main ] || { echo 'Run module audit on main.' >&2; exit 1; }
    for n in $(seq -w 1 20); do
      bash scripts/reseed.sh >/dev/null
      timeout 220 bash "exploits/$n/run.sh"
      bash scripts/reseed.sh >/dev/null
      rc=0; timeout 220 bash "tests/$n/test.sh" || rc=$?
      [ "$rc" = 1 ] || { echo "test $n: expected exit 1 on main; got $rc" >&2; exit 1; }
    done
    echo 'Twenty supplied module checks matched main expectations.' ;;
  *) echo 'Usage: bash scripts/audit.sh [--modules]' >&2; exit 2 ;;
esac
