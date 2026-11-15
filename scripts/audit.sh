#!/usr/bin/env bash
# Core readiness by default. Module mode validates the twenty supplied modules.
#
#   scripts/audit.sh              core readiness (smoke)
#   scripts/audit.sh --modules    on main: every exploit exits 0, every test exits 1
#   scripts/audit.sh --branches   plus every fix/NN: test 0, exploit 1, then back to main
#   scripts/audit.sh --branches 06 07   same, restricted to a subset
set -euo pipefail
source "$(dirname "$0")/common.sh"

ALL=$(seq -w 1 20)

artifacts_present() {
  local missing=0 n
  for n in $ALL; do
    for file in "exploits/$n/run.sh" "tests/$n/test.sh" "exploits/$n/README.md" "modules/$n/notes.md"; do
      [ -s "$file" ] || { echo "MISSING $file"; missing=1; }
    done
    git rev-parse --verify -q "refs/heads/fix/$n" >/dev/null || { echo "MISSING local branch fix/$n"; missing=1; }
  done
  [ "$missing" = 0 ] || { echo 'Cannot validate twenty modules: original artifacts are absent.' >&2; exit 1; }
}

require_clean_main() {
  [ "$(git branch --show-current)" = main ] || { echo 'Run the module audit on main.' >&2; exit 1; }
  git diff --quiet && git diff --cached --quiet || { echo 'Working tree is dirty; commit or stash first.' >&2; exit 1; }
}

case "${1:-}" in
  '')
    exec bash scripts/smoke.sh
    ;;

  --modules)
    artifacts_present
    require_clean_main
    failed=0
    for n in $ALL; do
      bash scripts/reseed.sh >/dev/null 2>&1
      erc=0; timeout 240 bash "exploits/$n/run.sh" >/dev/null 2>&1 || erc=$?
      bash scripts/reseed.sh >/dev/null 2>&1
      trc=0; timeout 240 bash "tests/$n/test.sh" >/dev/null 2>&1 || trc=$?
      if [ "$erc" = 0 ] && [ "$trc" = 1 ]; then
        echo "  ok    module $n (exploit 0, test 1 on main)"
      else
        echo "  FAIL  module $n: exploit exit $erc (want 0), test exit $trc (want 1)"
        failed=1
      fi
    done
    [ "$failed" = 0 ] && echo 'Twenty supplied module checks matched main expectations.' \
      || { echo 'Some modules did not match main expectations (see FAIL lines).' >&2; exit 1; }
    ;;

  --branches)
    artifacts_present
    require_clean_main
    shift
    sel=("$@"); [ ${#sel[@]} -gt 0 ] || sel=($(echo "$ALL"))

    echo '== main is flawed: exploits exit 0, tests exit 1'
    for n in "${sel[@]}"; do
      bash scripts/reseed.sh >/dev/null
      rc=0; timeout 240 bash "exploits/$n/run.sh" >/dev/null || rc=$?
      [ "$rc" = 0 ] || { echo "  FAIL  exploit $n: expected exit 0 on main; got $rc" >&2; exit 1; }
      echo "  ok    exploit $n exits 0 (flaw demonstrated)"
      bash scripts/reseed.sh >/dev/null
      rc=0; timeout 240 bash "tests/$n/test.sh" >/dev/null || rc=$?
      [ "$rc" = 1 ] || { echo "  FAIL  test $n: expected exit 1 on main; got $rc" >&2; exit 1; }
      echo "  ok    test $n exits 1 on main"
    done

    echo '== each fix branch flips'
    trap 'git checkout -f main >/dev/null 2>&1 || true' EXIT
    for n in "${sel[@]}"; do
      git checkout -f "fix/$n" >/dev/null
      # Many fixes are build or infra changes (Caddyfile, compose, Dockerfile, next.config,
      # nginx), so a reseed is not enough: rebuild the stack on the branch.
      bash scripts/reseed.sh >/dev/null 2>&1 || true
      make reset >/dev/null
      rc=0; timeout 240 bash "tests/$n/test.sh" >/dev/null || rc=$?
      [ "$rc" = 0 ] || { echo "  FAIL  fix/$n: test expected exit 0; got $rc" >&2; exit 1; }
      bash scripts/reseed.sh >/dev/null
      rc=0; timeout 240 bash "exploits/$n/run.sh" >/dev/null || rc=$?
      [ "$rc" = 1 ] || { echo "  FAIL  fix/$n: exploit expected exit 1; got $rc" >&2; exit 1; }
      echo "  ok    fix/$n: test 0, exploit 1"
      git checkout -f main >/dev/null
      make reset >/dev/null
    done
    trap - EXIT
    echo
    echo 'audit: everything checks out'
    ;;

  *)
    echo 'Usage: bash scripts/audit.sh [--modules | --branches [NN ...]]' >&2
    exit 2
    ;;
esac
