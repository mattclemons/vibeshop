#!/usr/bin/env bash
# fixed: the published postgres port is gone; the app path still reaches the db.
set -o pipefail
D="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$D/../../scripts/env.sh"
command -v docker >/dev/null 2>&1 || { echo 'docker required for module 6'; exit 2; }
net="vs-t6-$$"; docker network create "$net" >/dev/null 2>&1 || true
out=$(docker run --rm --network "$net" -e PGPASSWORD=vibeshop postgres:16-alpine \
  psql -h "$LAB_IP" -U vibeshop -d vibeshop -tAc 'select 1' 2>&1) || true
docker network rm "$net" >/dev/null 2>&1 || true
printf '%s' "$out" | grep -qx '1' && fail "external db still reachable" || pass "external db connection refused"
loc=$("${PSQL[@]}" -c 'select 1' | tr -d '[:space:]')
[ "$loc" = 1 ] && pass "compose exec psql still works" || fail "local db path broken ($loc)"
