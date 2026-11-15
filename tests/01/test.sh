#!/usr/bin/env bash
# fixed: the admin page verifies the session itself; middleware is only an early exit.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
H='x-middleware-subrequest: middleware:middleware:middleware:middleware:middleware'
by=$(C -o /dev/null -w '%{http_code}' -H "$H" "$BASE8080/admin")
[ "$by" = 307 ] && pass "loop-guard header redirects ($by)" || fail "bypass header still reaches admin ($by)"
no=$(C -o /dev/null -w '%{http_code}' "$BASE8080/admin")
[ "$no" = 307 ] && pass "no session redirects" || fail "no session not redirected ($no)"
mt=$(C -X POST -H 'content-type: application/json' -d '{"email":"maya@vibeshop.test","password":"sunshine"}' "$BASE8080/api/login" | python3 -c 'import sys,json;print(json.load(sys.stdin)["token"])')
mc=$(C -o /dev/null -w '%{http_code}' -H "cookie: vs_session=$mt" "$BASE8080/admin")
[ "$mc" = 307 ] && pass "non-admin session redirected" || fail "customer reached admin ($mc)"
at=$(C -X POST -H 'content-type: application/json' -d '{"email":"admin@vibeshop.test","password":"admin123"}' "$BASE8080/api/login" | python3 -c 'import sys,json;print(json.load(sys.stdin)["token"])')
ac=$(C -o /dev/null -w '%{http_code}' -H "cookie: vs_session=$at" "$BASE8080/admin")
[ "$ac" = 200 ] && pass "admin session reaches admin" || fail "admin session blocked ($ac)"
C -H "cookie: vs_session=$at" "$BASE8080/admin" | grep -q 'admin@vibeshop.test' && pass "admin table renders" || fail "no admin table"
