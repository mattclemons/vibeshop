#!/usr/bin/env bash
# fixed: hostile quantities are refused with the value quoted; the promo assigns once.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
J="/tmp/t20.$$"; C -c "$J" -o /dev/null "$BASE8080/api/cart"
for q in 0 -1 1.5 abc; do
  resp=$(C -b "$J" -c "$J" -w '\n%{http_code}' -X POST "$BASE8080/api/cart?product_id=8&qty=$q")
  code=${resp##*$'\n'}; body=${resp%$'\n'*}
  [ "$code" = 400 ] && pass "qty=$q rejected (400)" || fail "qty=$q -> $code"
  printf '%s' "$body" | grep -qF "$q" && pass "qty=$q quoted back" || fail "qty=$q not echoed"
done
C -b "$J" -c "$J" -o /dev/null -X POST "$BASE8080/api/cart?product_id=8&qty=3"
for i in $(seq 1 12); do C -b "$J" -c "$J" -o /dev/null -X POST "$BASE8080/api/cart/promo?code=VIBE10"; done
st=$(C -b "$J" "$BASE8080/api/cart")
disc=$(printf '%s' "$st" | python3 -c 'import sys,json;print(json.load(sys.stdin)["promo"]["discount"])')
tot=$(printf '%s' "$st" | python3 -c 'import sys,json;print(json.load(sys.stdin)["total"])')
python3 -c "import sys; sys.exit(0 if abs(float('$disc')-0.1)<1e-9 else 1)" && pass "twelve clicks still 0.1 discount" || fail "discount stacked to $disc"
[ "$tot" = 13497 ] && pass "total is 13497" || fail "total is $tot"
ord=$(C -b "$J" -X POST "$BASE8080/api/cart/checkout" | python3 -c 'import sys,json;print(json.load(sys.stdin)["order"]["amount"])')
rm -f "$J"
[ "$ord" = 13497 ] && pass "checkout stored a positive 13497" || fail "order amount $ord"
