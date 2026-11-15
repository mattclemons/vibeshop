#!/usr/bin/env bash
# fixed: off-site goes to the shop root, a host-relative path is honoured, tricks land on root.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
off=$(C -o /dev/null -w '%{redirect_url}' "$BASE8080/out?to=http://evil.test/phish")
printf '%s' "$off" | grep -q 'evil.test' && fail "off-site still followed ($off)" || pass "off-site refused"
rel=$(C -o /dev/null -w '%{redirect_url}' "$BASE8080/out?to=/login")
printf '%s' "$rel" | grep -q '/login' && pass "host-relative honoured" || fail "relative path broke ($rel)"
proto=$(C -o /dev/null -w '%{redirect_url}' "$BASE8080/out?to=//evil.test")
printf '%s' "$proto" | grep -q 'evil.test' && fail "protocol-relative escaped ($proto)" || pass "protocol-relative contained"
jsloc=$(C -o /dev/null -w '%{redirect_url}' "$BASE8080/out?to=javascript:alert(1)")
printf '%s' "$jsloc" | grep -qi '^javascript:' && fail "javascript scheme passed through" || pass "javascript scheme neutralised"
