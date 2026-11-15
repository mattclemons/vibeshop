#!/usr/bin/env bash
# fixed: Caddy no longer serves the checkout .git directory.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
code=$(C -o /dev/null -w '%{http_code}' "$BASE/.git/HEAD")
[ "$code" = 404 ] && pass "/.git/HEAD not served ($code)" || fail "/.git still served ($code)"
rc=0; python3 "$D/../../exploits/02/walk.py" "$BASE/.git" >/dev/null 2>&1 || rc=$?
[ "$rc" != 0 ] && pass "history not walkable over http" || fail "key still retrievable over http"
s=$(C -o /dev/null -w '%{http_code}' "$BASE/"); [ "$s" = 200 ] && pass "shop still serves" || fail "shop down ($s)"
