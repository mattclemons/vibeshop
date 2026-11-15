#!/usr/bin/env bash
# fixed: checkout charges the catalogue price and ignores the posted amount.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
resp=$(C -X POST -H 'content-type: application/json' -d '{"productId":8,"amount":1}' "$BASE/api/checkout")
charged=$(printf '%s' "$resp" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("charged_cents"))')
[ "$charged" = 4999 ] && pass "underpay ignored, charged 4999" || fail "charged $charged not 4999"
last=$("${PSQL[@]}" -c "select amount from orders order by id desc limit 1" | tr -d '[:space:]')
[ "$last" = 4999 ] && pass "order row is 4999" || fail "order row $last"
hi=$(C -X POST -H 'content-type: application/json' -d '{"productId":8,"amount":99999}' "$BASE/api/checkout" | python3 -c 'import sys,json;print(json.load(sys.stdin).get("charged_cents"))')
[ "$hi" = 4999 ] && pass "overpay also ignored, charged 4999" || fail "overpay charged $hi"
