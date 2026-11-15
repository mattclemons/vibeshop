#!/usr/bin/env bash
# fixed: the advertised legacy host is answered by the shop, and the dangling link is gone.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
tmp="/tmp/t10.$$"
hdr=$(C -D - -o "$tmp" -H 'Host: legacy.vibeshop.test' "http://$LAB_IP/")
server=$(printf '%s' "$hdr" | grep -i '^server:' | tr -d '\r')
printf '%s' "$server" | grep -qi nginx && { rm -f "$tmp"; fail "attacker nginx still answers ($server)"; }
pass "advertised host not served by nginx"
grep -q 'VibeShop' "$tmp" && pass "shop body returned for the legacy host" || { rm -f "$tmp"; fail "no shop body for legacy host"; }
rm -f "$tmp"
C "$BASE8080/" | grep -q 'legacy.vibeshop.test' && fail "footer still advertises legacy" || pass "footer link removed"
