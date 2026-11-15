#!/usr/bin/env bash
# fixed: the stored review and the reflected term both come back as entities.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
clean(){ "${PSQL[@]}" -c "DELETE FROM reviews WHERE author='attacker' AND product_id=1" >/dev/null 2>&1 || true; }
P='<img src=x onerror="document.title=1">'
C -o /dev/null -X POST --data-urlencode "author=attacker" --data-urlencode "body=$P" "$BASE8080/api/reviews?product_id=1"
html=$(C "$BASE8080/product/1")
printf '%s' "$html" | grep -q '<img src=x onerror' && { clean; fail "stored review renders as live markup"; }
pass "stored review is not live markup"
printf '%s' "$html" | grep -q '&lt;img src=x onerror' && pass "review body is entity-encoded" || { clean; fail "review not entity-encoded"; }
clean
refl=$(C "$BASE8080/product/1?q=%22%20autofocus%20onfocus%3D%22alert(1)")
printf '%s' "$refl" | grep -q 'data-term="" autofocus' && fail "reflected quote broke the attribute" || pass "reflected attribute not broken"
printf '%s' "$refl" | grep -q 'data-term="&quot;' && pass "reflected quote entity-encoded" || fail "reflected quote not encoded"
