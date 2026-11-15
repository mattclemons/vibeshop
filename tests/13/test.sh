#!/usr/bin/env bash
# fixed: the map is still served and names the file, but sourcesContent is gone.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
ch=$(C "$BASE8080/login" | grep -o '/_next/static/chunks/[^"]*\.js' | head -1)
[ -n "$ch" ] || fail "no chunk reference on /login"
code=$(C -o /dev/null -w '%{http_code}' "$BASE8080$ch.map")
[ "$code" = 200 ] && pass "map still served ($code)" || fail "map missing ($code)"
n=$(C "$BASE8080$ch.map" | grep -c 'sourcesContent' || true)
[ "${n:-0}" = 0 ] && pass "no sourcesContent published" || fail "sourcesContent present ($n)"
