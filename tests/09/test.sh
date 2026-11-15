#!/usr/bin/env bash
# fixed: an unconfirmed squatted row has its password retired when the provider identity merges.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
EM="walk$$@vibeshop.test"
C -X POST -H 'content-type: application/json' -d "{\"email\":\"$EM\",\"password\":\"attacker123\"}" "$BASE/api/signup" >/dev/null
hdr=$(C -D - -o /dev/null -L "$BASE/api/oauth/provider?email=$EM&redirect_uri=/api/oauth/callback")
retired=$(printf '%s' "$hdr" | grep -i '^x-oauth-password-retired:' | tr -d '\r' | awk '{print $2}')
code=$(C -o /dev/null -w '%{http_code}' -X POST -H 'content-type: application/json' -d "{\"email\":\"$EM\",\"password\":\"attacker123\"}" "$BASE/api/login")
confirmed=$("${PSQL[@]}" -c "select email_confirmed from users where email='$EM' order by id limit 1" | tr -d '[:space:]')
"${PSQL[@]}" -c "DELETE FROM users WHERE email='$EM'" >/dev/null 2>&1 || true
[ "$code" = 401 ] && pass "squatted password retired ($code)" || fail "attacker password survived ($code)"
[ "$retired" = true ] && pass "x-oauth-password-retired header set" || fail "no retired header"
[ "$confirmed" = t ] && pass "provider identity merged (confirmed)" || fail "row not confirmed ($confirmed)"
