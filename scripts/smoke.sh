#!/usr/bin/env bash
# Readiness and seed checks, not a substitute for exploit/fix regression tests.
set -euo pipefail
source "$(dirname "$0")/common.sh"
get() { curl --noproxy '*' -fsS --max-time 15 "$1"; }
get "http://$LAB_IP:8080/api/whoami" | jq -e '.method == "GET"' >/dev/null
get "http://$LAB_IP:8080/" | grep -q VibeShop
get "http://$LAB_IP:9000/minio/health/live" >/dev/null
get "http://$LAB_IP:9000/uploads/index.txt" | grep -q 'id-12-nina.txt'
get 'http://169.254.169.254/latest/meta-data/instance-id' | grep -q 'i-0junk'
get "http://$LAB_IP:8081/tracker.js" | grep -q vibeshopTracker
get "http://$LAB_IP:8025/api/v2/messages" | jq -e '.total >= 0' >/dev/null
counts="$(compose exec -T postgres psql -tAU vibeshop -d vibeshop -c "SELECT (SELECT count(*) FROM users) || chr(58) || (SELECT count(*) FROM products);" 2>/dev/null)"
[ "$counts" = '8:40' ] || { echo "Unexpected seed counts: $counts" >&2; exit 1; }
echo 'PASS: app, bucket, metadata, attacker origin, mail and seed counts.'
