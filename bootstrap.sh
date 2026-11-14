#!/usr/bin/env bash
# Clone on the Debian 12 lab VM, then run: ./bootstrap.sh --local --host-ip 10.3.10.137
# Remote: ./bootstrap.sh --target maint@10.3.10.137 --host-ip 10.3.10.137
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
LOCAL=0 TARGET= HOST_IP= CLIENT_NET= PLAN=0 NO_INSTALL=0
usage() {
  cat <<'EOF'
Usage: ./bootstrap.sh --local [--host-ip IPv4] [--client-net CIDR] [--no-install] [--plan]
       ./bootstrap.sh --target user@host --host-ip IPv4 [--client-net CIDR] [--plan]
Local mode runs from this checkout. Remote mode copies the checkout, including .git,
to a new directory under ~/vibeshop-labs on the target. It never replaces another checkout.
The lab requires Debian 12 amd64, 4 GB RAM recommended and 10 GB free disk.
--plan is read-only and makes no network connection.
EOF
}
while [ "$#" -gt 0 ]; do
  case "$1" in
    --local) LOCAL=1 ;;
    --target|--host-ip|--client-net)
      [ "$#" -ge 2 ] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in --target) TARGET="$2" ;; --host-ip) HOST_IP="$2" ;; --client-net) CLIENT_NET="$2" ;; esac
      shift ;;
    --plan) PLAN=1 ;;
    --no-install) NO_INSTALL=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done
if [ "$PLAN" = 1 ]; then
  cat <<EOF
Mode: $([ "$LOCAL" = 1 ] && echo local || echo remote); target: ${TARGET:-none}
Lab IP: ${HOST_IP:-detected on the Debian VM}; extra client CIDR: ${CLIENT_NET:-none}
1. Check Debian 12 amd64, IP assignment, disk space and sudo.
2. Install Debian docker.io, iptables, Python, curl, jq, make and related tools.
3. Install Compose v2.29.7 with its published SHA-256 if Compose is absent.
4. Write ignored .lab.env, add a marked /etc/hosts block, alias metadata IP on lo.
5. Add lab-only INPUT and DOCKER-USER chains, preserving unrelated rules.
6. Validate Compose, pull images, build, start and wait for HTTP readiness.
7. Load schema/fixtures, populate anonymous bucket and run smoke checks.
8. Print URLs. No twenty-module validation is claimed without those artifacts.
EOF
  exit 0
fi
ARGS=()
[ -z "$HOST_IP" ] || ARGS+=(--host-ip "$HOST_IP")
[ -z "$CLIENT_NET" ] || ARGS+=(--client-net "$CLIENT_NET")
[ "$NO_INSTALL" = 0 ] || ARGS+=(--no-install)
if [ "$LOCAL" = 1 ]; then
  [ -z "$TARGET" ] || { echo 'Choose --local or --target, not both.' >&2; exit 2; }
  if [ "$(id -u)" = 0 ]; then exec bash "$ROOT/scripts/bootstrap-stage.sh" "${ARGS[@]}"; fi
  exec sudo bash "$ROOT/scripts/bootstrap-stage.sh" "${ARGS[@]}"
fi
[ -n "$TARGET" ] && [ -n "$HOST_IP" ] || { usage >&2; exit 2; }
# Restrict target syntax before passing it to ssh; arguments are quoted with Bash printf %q.
[[ "$TARGET" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.@:-]*$ ]] || { echo 'Invalid SSH target' >&2; exit 2; }
SSH=(ssh -o ConnectTimeout=15 -o ServerAliveInterval=30)
REMOTE="$("${SSH[@]}" "$TARGET" 'mkdir -p "$HOME/vibeshop-labs"; mktemp -d "$HOME/vibeshop-labs/lab.XXXXXXXX"')"
[[ "$REMOTE" =~ ^/[a-zA-Z0-9_./-]+/lab\.[a-zA-Z0-9]+$ ]] || exit 2
tar -czf - --exclude=node_modules --exclude=.next --exclude=.lab-state --exclude=.lab.env -C "$ROOT" . |
  "${SSH[@]}" "$TARGET" "tar -xzf - -C '$REMOTE'"
printf -v CMD '%q ' bash "$REMOTE/bootstrap.sh" --local "${ARGS[@]}"
"${SSH[@]}" -t "$TARGET" "$CMD"
