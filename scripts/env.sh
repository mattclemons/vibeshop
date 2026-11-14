#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
export HOST="$LAB_IP" SHOP=vibeshop.test BASE=http://vibeshop.test ROOTURL=http://vibeshop.test/
export BASE8080=http://vibeshop.test:8080 ORIGIN="http://$LAB_IP:3000"
export MINIO="http://$LAB_IP:9000" MAILHOG="http://$LAB_IP:8025"
export ATTACKER=http://attacker.test:8081 LEGACYURL=http://legacy.vibeshop.test:8081
export METADATA=http://169.254.169.254 CIDIR="$ROOT"
PSQL=(bash "$ROOT/scripts/compose.sh" exec -T postgres psql -tAU vibeshop -d vibeshop -q)
pass() { printf 'PASS %s\n' "$1"; }
fail() { printf 'FAIL %s\n' "$1"; exit 1; }
