#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
[ "$(id -u)" = 0 ] || { echo 'Run through bootstrap.sh --local (uses sudo).' >&2; exit 2; }
HOST_IP= CLIENT= NO_INSTALL=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --host-ip) HOST_IP="$2"; shift ;;
    --client-net) CLIENT="$2"; shift ;;
    --no-install) NO_INSTALL=1 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done
. /etc/os-release
[ "${ID:-}" = debian ] && [ "${VERSION_ID:-}" = 12 ] || { echo 'Use a disposable Debian 12 VM.' >&2; exit 1; }
[ "$(uname -m)" = x86_64 ] || { echo 'This package targets amd64. MailHog image architecture has not been validated on arm64.' >&2; exit 1; }
[ "$(df -Pk . | awk 'NR==2{print $4}')" -ge 10485760 ] || { echo 'Need 10 GiB free.' >&2; exit 1; }
if [ "$NO_INSTALL" = 0 ]; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y iptables iproute2 python3 ca-certificates curl jq git make dnsutils
  if ! command -v docker >/dev/null 2>&1; then DEBIAN_FRONTEND=noninteractive apt-get install -y docker.io; fi
fi
command -v python3 docker ip iptables curl jq make git >/dev/null
systemctl enable --now docker
if ! docker compose version >/dev/null 2>&1; then
  [ "$NO_INSTALL" = 0 ] || { echo 'Compose plugin missing.' >&2; exit 1; }
  work="$(mktemp -d)"
  trap 'rm -rf "$work"' EXIT
  release='https://github.com/docker/compose/releases/download/v2.29.7'
  curl -fL --retry 3 "$release/docker-compose-linux-x86_64" -o "$work/docker-compose-linux-x86_64"
  curl -fL --retry 3 "$release/checksums.txt" -o "$work/checksums.txt"
  (cd "$work"; grep -E ' [ *]?docker-compose-linux-x86_64$' checksums.txt > selected.sha256; test -s selected.sha256; sha256sum -c selected.sha256)
  install -D -m 0755 "$work/docker-compose-linux-x86_64" /usr/local/lib/docker/cli-plugins/docker-compose
fi
if [ -z "$CLIENT" ] && [ -f .lab.env ]; then CLIENT="$(sed -n 's/^CLIENT_NET=//p' .lab.env)"; fi
if [ -z "$HOST_IP" ]; then
  if [ -f .lab.env ]; then HOST_IP="$(sed -n 's/^LAB_IP=//p' .lab.env)";
  else HOST_IP="$(ip -4 route get 1.1.1.1 | sed -n 's/.* src \([^ ]*\).*/\1/p' | head -1)"; fi
fi
python3 - "$HOST_IP" "$CLIENT" <<'PYCODE'
import ipaddress,sys
ip=ipaddress.IPv4Address(sys.argv[1])
if ip.is_loopback or ip.is_link_local or ip.is_unspecified or ip.is_multicast:
    raise SystemExit('Use the VM LAN IPv4 address.')
if sys.argv[2]: ipaddress.IPv4Network(sys.argv[2],strict=False)
PYCODE
ip -4 -o addr show | awk '{print $4}' | cut -d/ -f1 | grep -Fxq "$HOST_IP" || { echo "IP $HOST_IP is not assigned to this VM." >&2; exit 1; }
if [ -f .lab.env ]; then
  OLD="$(sed -n 's/^LAB_IP=//p' .lab.env)"
  [ "$OLD" = "$HOST_IP" ] || { echo 'Changing IP requires make clean before rerunning bootstrap.' >&2; exit 1; }
fi
umask 022
printf 'LAB_IP=%s\nCLIENT_NET=%s\n' "$HOST_IP" "$CLIENT" > .lab.env
# The first bootstrap owns one marked hosts block. Repeated runs replace only that block.
python3 - "$HOST_IP" <<'PYCODE'
from pathlib import Path
import re,sys
p=Path('/etc/hosts');text=p.read_text()
text=re.sub(r'\n?# BEGIN VIBESHOP\n.*?# END VIBESHOP\n?', '\n', text, flags=re.S)
text=text.rstrip()+'\n\n# BEGIN VIBESHOP\n'+sys.argv[1]+' vibeshop.test attacker.test legacy.vibeshop.test evil.test\n# END VIBESHOP\n'
p.write_text(text)
PYCODE
bash scripts/alias.sh
bash scripts/guard.sh
bash scripts/doctor.sh
bash scripts/compose.sh config --quiet
bash scripts/compose.sh pull --ignore-buildable
bash scripts/compose.sh up -d --build --force-recreate
bash scripts/wait.sh
bash scripts/reseed.sh
bash scripts/smoke.sh
cat <<EOF
Ready: http://vibeshop.test:8080/
Admin: http://vibeshop.test:8080/admin
Mail: http://$HOST_IP:8025/ ; bucket: http://$HOST_IP:9000/uploads/index.txt
On your browser computer add: $HOST_IP vibeshop.test attacker.test legacy.vibeshop.test evil.test
Credentials: maya@vibeshop.test / sunshine ; admin@vibeshop.test / admin123
Checkout: $(pwd)
Run make smoke after setup; make reset discards the fixture database and reloads it.
See RELEASE-CHECKLIST.md before publishing the twenty-module claims.
EOF
