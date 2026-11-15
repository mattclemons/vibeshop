#!/usr/bin/env bash
# fixed: the reset link is built from a configured origin, not the request Host.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
resp=$(C -X POST -H 'Host: evil.test' -H 'content-type: application/json' -d '{"email":"quinn@vibeshop.test"}' "$BASE8080/api/forgot")
link=$(printf '%s' "$resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("link",""))')
printf '%s' "$link" | grep -q 'evil.test' && fail "link follows the Host ($link)" || pass "link ignores the Host"
printf '%s' "$link" | grep -q 'vibeshop.test' && pass "link uses the configured origin" || fail "link not on vibeshop.test ($link)"
