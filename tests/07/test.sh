#!/usr/bin/env bash
# fixed: the tracker tag carries integrity + crossorigin, and the host allows the SRI read.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
tag=$(C "$BASE8080/" | grep -o '<script[^>]*tracker\.js[^>]*>' | head -1)
printf '%s' "$tag" | grep -qi 'integrity=' && pass "integrity present" || fail "no integrity attribute"
printf '%s' "$tag" | grep -qi 'crossorigin' && pass "crossorigin present" || fail "no crossorigin attribute"
acao=$(C -D - -o /dev/null "$ATTACKER/tracker.js" | grep -i 'access-control-allow-origin')
[ -n "$acao" ] && pass "ACAO on the tracker host" || fail "no Access-Control-Allow-Origin"
want=$(C "$ATTACKER/tracker.js" | openssl dgst -sha384 -binary | openssl base64 -A)
printf '%s' "$tag" | grep -qF "sha384-$want" && pass "integrity matches the served file" || fail "integrity does not match served file"
