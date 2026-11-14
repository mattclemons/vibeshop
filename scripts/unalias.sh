#!/usr/bin/env bash
# Undo only the lab-owned chains, marked hosts block and alias created by this checkout.
set -euo pipefail
source "$(dirname "$0")/common.sh"
IPT=(iptables -w); [ "$(id -u)" = 0 ] || IPT=(sudo iptables -w)
ports='80,8080,8081,3000,5432,8025,9000,9001'
while "${IPT[@]}" -C INPUT -d "$LAB_IP" -p tcp -m multiport --dports "$ports" -j VIBESHOP-IN 2>/dev/null; do
  "${IPT[@]}" -D INPUT -d "$LAB_IP" -p tcp -m multiport --dports "$ports" -j VIBESHOP-IN
done
for port in 3000 5432 8025 8081 9000 9001; do
  while "${IPT[@]}" -C DOCKER-USER -p tcp -m conntrack --ctorigdst "$LAB_IP" --ctorigdstport "$port" -j VIBESHOP-FWD 2>/dev/null; do
    "${IPT[@]}" -D DOCKER-USER -p tcp -m conntrack --ctorigdst "$LAB_IP" --ctorigdstport "$port" -j VIBESHOP-FWD
  done
done
for chain in VIBESHOP-IN VIBESHOP-FWD; do
  if "${IPT[@]}" -S "$chain" >/dev/null 2>&1; then "${IPT[@]}" -F "$chain"; "${IPT[@]}" -X "$chain"; fi
done
if [ -f .lab-state/metadata-alias-owned ]; then
  if ip -4 -o addr show dev lo | grep -q '169.254.169.254/32'; then sudo_if_needed ip addr del 169.254.169.254/32 dev lo; fi
fi
sudo_if_needed python3 - <<'PYCODE'
from pathlib import Path
import re
p=Path('/etc/hosts');p.write_text(re.sub(r'\n?# BEGIN VIBESHOP\n.*?# END VIBESHOP\n?', '\n',p.read_text(),flags=re.S))
PYCODE
sudo_if_needed rm -rf .lab-state .lab.env
echo 'Lab networking removed. Docker/packages remain installed.'
