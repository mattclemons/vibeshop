#!/usr/bin/env bash
# fixed: login throttles per address and per account, without a global lockout.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
got=0; i=0
while [ $i -lt 40 ]; do i=$((i+1))
  code=$(C -o /dev/null -w '%{http_code}' -X POST -H 'content-type: application/json' -d "{\"email\":\"maya@vibeshop.test\",\"password\":\"x$i\"}" "$BASE8080/api/login")
  [ "$code" = 429 ] && { got=1; break; }
done
[ "$got" = 1 ] && pass "login throttled after $i attempts" || fail "never throttled in $i attempts"
ra=$(C -D - -o /dev/null -X POST -H 'content-type: application/json' -d '{"email":"maya@vibeshop.test","password":"x"}' "$BASE8080/api/login" | grep -i 'retry-after')
[ -n "$ra" ] && pass "retry-after present" || fail "no retry-after header"
ok=$(C -o /dev/null -w '%{http_code}' -X POST -H 'content-type: application/json' -d '{"email":"leo@vibeshop.test","password":"qwerty"}' "$BASE8080/api/login")
[ "$ok" = 200 ] && pass "unrelated account still logs in" || fail "lockout too broad ($ok)"
