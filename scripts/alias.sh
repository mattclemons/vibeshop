#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/common.sh"
mkdir -p .lab-state
if ! ip -4 -o addr show dev lo | grep -q '169.254.169.254/32'; then
  sudo_if_needed ip addr add 169.254.169.254/32 dev lo
  touch .lab-state/metadata-alias-owned
fi
ip route get 169.254.169.254
