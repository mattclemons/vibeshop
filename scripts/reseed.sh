#!/usr/bin/env bash
# Destructive only to the VibeShop fixture schema and bucket objects.
set -euo pipefail
source "$(dirname "$0")/common.sh"
compose exec -T postgres psql -q -U vibeshop -d vibeshop -v ON_ERROR_STOP=1 \
  -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;' >/dev/null
for file in 01-schema.sql 02-seed.sql; do
  compose exec -T postgres psql -q -U vibeshop -d vibeshop -v ON_ERROR_STOP=1 -f "/docker-entrypoint-initdb.d/$file" >/dev/null
done
compose run --rm --no-deps minio-setup
compose exec -T postgres psql -tAU vibeshop -d vibeshop \
  -c "SELECT 'users=' || (SELECT count(*) FROM users) || ', products=' || (SELECT count(*) FROM products);"
