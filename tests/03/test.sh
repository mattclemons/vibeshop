#!/usr/bin/env bash
# fixed: anonymous download is denied; the bucket still exists for signed requests.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
C(){ curl -s --noproxy '*' --max-time 25 "$@"; }
code=$(C -o /dev/null -w '%{http_code}' "$MINIO/uploads/id-01-maya.txt")
[ "$code" = 403 ] && pass "anonymous download denied ($code)" || fail "anonymous still allowed ($code)"
C "$MINIO/uploads/id-01-maya.txt" | grep -q 'AccessDenied' && pass "AccessDenied body is the tell" || fail "no AccessDenied body"
h=$(C -o /dev/null -w '%{http_code}' "$MINIO/minio/health/live"); [ "$h" = 200 ] && pass "minio healthy" || fail "minio down ($h)"
