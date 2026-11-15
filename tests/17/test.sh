#!/usr/bin/env bash
# fixed: the value is bound and the sort column allowlisted, at both call sites.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
inj=$(C "$BASE8080/api/search?q=%27%20OR%201%3D1--")
cnt=$(printf '%s' "$inj" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("count",-1))')
[ "$cnt" = 0 ] && pass "OR 1=1 returns 0 rows (api)" || fail "injection returned $cnt rows"
sql=$(printf '%s' "$inj" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("sql",""))')
printf '%s' "$sql" | grep -qF 'ILIKE $1' && pass "value is bound (ILIKE \$1)" || fail "value not bound: $sql"
sc=$(C -o /dev/null -w '%{http_code}' "$BASE8080/api/search?q=&sort=price")
[ "$sc" = 200 ] && pass "unknown sort handled (no 500)" || fail "sort=price -> $sc"
un=$(C "$BASE8080/api/search?q=%25%27%20UNION%20SELECT%20id%2C%20email%2C%200%2C%20password_hash%20FROM%20users--" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("count",-1))')
[ "$un" = 0 ] && pass "union returns nothing" || fail "union leaked $un rows"
C "$BASE8080/search?q=%27%20OR%201%3D1--" | grep -qF 'ILIKE $1' && pass "page call site binds too" || fail "page still interpolates"
good=$(C "$BASE8080/api/search?q=Mug" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("count",0))')
[ "${good:-0}" -ge 1 ] && pass "a real search term still matches" || fail "real search broke ($good)"
