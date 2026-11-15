#!/usr/bin/env bash
# fixed: every orders query is scoped by the session; the owner can still read their own.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
JAR="/tmp/t18.$$"
C -c "$JAR" -o /dev/null -X POST -H 'content-type: application/json' -d '{"email":"leo@vibeshop.test","password":"qwerty"}' "$BASE8080/api/login"
before=$("${PSQL[@]}" -c "select status from orders where id=2" | tr -d '[:space:]')
code=$(C -o /dev/null -w '%{http_code}' -b "$JAR" -X POST "$BASE8080/api/orders?id=2")
after=$("${PSQL[@]}" -c "select status from orders where id=2" | tr -d '[:space:]')
{ [ "$code" = 404 ] && [ "$before" = paid ] && [ "$after" = paid ]; } && pass "cancel refused, row untouched" || fail "cancel code=$code before=$before after=$after"
r=$(C -o /dev/null -w '%{http_code}' -b "$JAR" "$BASE8080/api/orders?id=2")
[ "$r" = 404 ] && pass "another customer order is not readable" || fail "read returned $r"
lst=$(C -b "$JAR" "$BASE8080/api/orders" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d["count"], all(o["mine"] for o in d["orders"]))')
printf '%s' "$lst" | grep -Eq '^[0-9]+ True$' && pass "list is scoped to the caller ($lst)" || fail "list leaks: $lst"
out=$(C -o /dev/null -w '%{http_code}' "$BASE8080/order/2")
printf '%s' "$out" | grep -q '^3' && pass "receipt redirects when logged out ($out)" || fail "receipt logged-out $out"
inn=$(C -o /dev/null -w '%{http_code}' -b "$JAR" "$BASE8080/order/2")
[ "$inn" = 404 ] && pass "receipt 404 for a non-owner" || fail "receipt non-owner $inn"
rm -f "$JAR"
MJ="/tmp/t18m.$$"
C -c "$MJ" -o /dev/null -X POST -H 'content-type: application/json' -d '{"email":"maya@vibeshop.test","password":"sunshine"}' "$BASE8080/api/login"
own=$(C -b "$MJ" "$BASE8080/api/orders?id=1" | python3 -c 'import sys,json;d=json.load(sys.stdin);print(d.get("order",{}).get("id"),d.get("mine"))')
rm -f "$MJ"
[ "$own" = "1 True" ] && pass "the owner can read their own order" || fail "owner read broke ($own)"
