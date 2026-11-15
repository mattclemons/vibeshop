#!/usr/bin/env bash
# fixed: an off-allowlist host is a 400 naming the allowlist; a permitted host still imports.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
ext=$(C "$BASE8080/api/import?url=http://example.com/")
st=$(printf '%s' "$ext" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("status"))' 2>/dev/null)
err=$(printf '%s' "$ext" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("error",""))' 2>/dev/null)
[ "$st" != 200 ] && pass "off-allowlist host blocked" || fail "arbitrary host still fetched"
printf '%s' "$err" | grep -qi 'allow' && pass "error names the allowlist" || fail "no allowlist message: $err"
mio=$(C "$BASE8080/api/import?url=http://minio:9000/uploads/" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("status"))' 2>/dev/null)
[ "$mio" = 200 ] && pass "permitted host still imports" || fail "permitted host broken ($mio)"
