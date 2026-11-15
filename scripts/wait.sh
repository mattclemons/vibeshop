#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
wait_for() {
  local name="$1" url="$2" i
  for i in $(seq 1 90); do
    if curl --noproxy '*' -fsS --max-time 3 "$url" >/dev/null 2>&1; then echo "$name ready"; return 0; fi
    sleep 2
  done
  echo "Timed out waiting for $name ($url)" >&2
  compose logs --tail=40 >&2
  return 1
}
wait_for app "http://$LAB_IP:8080/api/whoami"
wait_for minio "http://$LAB_IP:9000/minio/health/live"
wait_for attacker "http://$LAB_IP:8081/"
wait_for mailhog "http://$LAB_IP:8025/api/v2/messages"
wait_for metadata 'http://169.254.169.254/latest/meta-data/instance-id'

# module 2: publish dumb-http git metadata so the served .git is cloneable (the exposure)
git update-server-info 2>/dev/null || true

