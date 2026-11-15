#!/usr/bin/env bash
# fixed: Caddy no longer serves the checkout .git directory.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
code=$(C -o /dev/null -w '%{http_code}' "$BASE/.git/HEAD")
[ "$code" = 404 ] && pass "/.git/HEAD not served ($code)" || fail "/.git still served ($code)"
work="$(mktemp -d)"; trap 'rm -rf "$work"' EXIT
if git -c http.proxy= clone -q "$BASE/.git" "$work/leak" 2>/dev/null; then
  fail "the .git repository is still cloneable over http"
fi
pass "history not cloneable over http"
s=$(C -o /dev/null -w '%{http_code}' "$BASE/"); [ "$s" = 200 ] && pass "shop still serves" || fail "shop down ($s)"
