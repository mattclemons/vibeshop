#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
[ "$(uname -s)" = Linux ] || { echo 'Runtime setup requires the Debian VM, not macOS.' >&2; exit 1; }
compose version
compose config --quiet
python3 - <<'PYCODE'
import json
from pathlib import Path
p=json.loads(Path('web/package.json').read_text())
l=json.loads(Path('web/package-lock.json').read_text())
assert p['dependencies']['next']=='15.2.2', 'Lab requires the vulnerable Next.js pin'
assert l['packages']['node_modules/next']['version']=='15.2.2'
print('Next.js 15.2.2 and lockfile present')
PYCODE
ip -4 -o addr show | awk '{print $4}' | cut -d/ -f1 | grep -Fxq "$LAB_IP"
ip -4 -o addr show dev lo | grep -q '169.254.169.254/32'
# Refuse conflicting services. Existing containers in this Compose project may own these ports.
for port in 80 8080 8081 3000 5432 8025 9000 9001; do
  if ss -lntH "sport = :$port" | grep -q .; then
    [ -n "$(compose ps -q)" ] || { echo "Port $port is already occupied." >&2; exit 1; }
  fi
done
echo 'doctor: pass'
