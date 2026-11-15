#!/usr/bin/env bash
# fixed: X-Frame-Options and CSP frame-ancestors are set.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
hdr=$(C -D - -o /dev/null "$BASE8080/")
printf '%s' "$hdr" | grep -qi 'x-frame-options' && pass "x-frame-options set" || fail "no x-frame-options"
printf '%s' "$hdr" | grep -qi 'frame-ancestors' && pass "frame-ancestors set" || fail "no frame-ancestors"
