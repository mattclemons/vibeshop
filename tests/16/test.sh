#!/usr/bin/env bash
# fixed: forgot, login and signup give one response shape for known and unknown addresses.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
g=$(C -w '\n%{http_code}' -X POST -H 'content-type: application/json' -d '{"email":"ghost@vibeshop.test"}' "$BASE8080/api/forgot")
k=$(C -w '\n%{http_code}' -X POST -H 'content-type: application/json' -d '{"email":"maya@vibeshop.test"}' "$BASE8080/api/forgot")
[ "${g##*$'\n'}" = "${k##*$'\n'}" ] && pass "forgot status identical (${g##*$'\n'})" || fail "forgot status differs"
[ "${g%$'\n'*}" = "${k%$'\n'*}" ] && pass "forgot body identical" || fail "forgot body differs"
lu=$(C -w '\n%{http_code}' -X POST -H 'content-type: application/json' -d '{"email":"ghost@vibeshop.test","password":"x"}' "$BASE8080/api/login")
lk=$(C -w '\n%{http_code}' -X POST -H 'content-type: application/json' -d '{"email":"maya@vibeshop.test","password":"wrong"}' "$BASE8080/api/login")
[ "${lu##*$'\n'}" = "${lk##*$'\n'}" ] && pass "login status identical" || fail "login status differs"
[ "${lu%$'\n'*}" = "${lk%$'\n'*}" ] && pass "login body identical" || fail "login body differs"
NE="enum$$@vibeshop.test"
su=$(C -X POST -H 'content-type: application/json' -d "{\"email\":\"$NE\",\"password\":\"p\"}" "$BASE8080/api/signup")
sk=$(C -X POST -H 'content-type: application/json' -d '{"email":"maya@vibeshop.test","password":"p"}' "$BASE8080/api/signup")
nu=$(printf '%s' "$su" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("note"))' 2>/dev/null)
nk=$(printf '%s' "$sk" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("note"))' 2>/dev/null)
"${PSQL[@]}" -c "DELETE FROM users WHERE email IN ('$NE','maya@vibeshop.test') AND email_confirmed = false" >/dev/null 2>&1 || true
[ "$nu" = "$nk" ] && pass "signup note identical for known and unknown" || fail "signup note differs ($nu vs $nk)"
