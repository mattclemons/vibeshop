#!/usr/bin/env bash
# fixed: the signing secret is a 64-char value, not in the wordlist.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
tok=$(C -X POST -H 'content-type: application/json' -d '{"email":"maya@vibeshop.test","password":"sunshine"}' "$BASE8080/api/login" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("token",""))')
[ -n "$tok" ] || fail "could not log in to get a token"
sec=$(python3 "$D/../../exploits/08/crack.py" jwt "$tok")
[ "$sec" = NOTFOUND ] && pass "secret not in the wordlist" || fail "secret cracked: $sec"
forged=$(python3 "$D/../../exploits/08/crack.py" forge sunshine '{"sub":999,"email":"root@vibeshop.test","role":"admin"}')
code=$(C -o /dev/null -w '%{http_code}' -H "cookie: vs_session=$forged" "$BASE8080/admin")
[ "$code" != 200 ] && pass "sunshine-forged token rejected ($code)" || fail "forged token still reaches admin"
ok=$(C -o /dev/null -w '%{http_code}' -H "cookie: vs_session=$tok" "$BASE8080/api/orders")
[ "$ok" = 200 ] && pass "a real session still verifies" || fail "real session broken ($ok)"
