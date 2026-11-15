#!/usr/bin/env bash
# Rebuild the twenty fix branches from main plus the committed .pkg payloads.
#
# The fix for module NN lives on main under .pkg/fixNN.*, so main stays flawed and every
# reviewer can diff the fix without checking out a branch. This script applies each payload
# onto its own branch, so fix/NN is exactly main plus that one fix.
#
#   scripts/make-fix-branches.sh            rebuild all twenty
#   scripts/make-fix-branches.sh 04 18 20   rebuild a subset
#
# Each branch is recreated with git checkout -B, so reruns are idempotent. main is never touched.
set -euo pipefail
cd "$(cd "$(dirname "$0")/.." && pwd)"

[ "$(git branch --show-current)" = main ] || { echo 'Run from main.' >&2; exit 1; }
git diff --quiet && git diff --cached --quiet || { echo 'Commit or stash changes on main first.' >&2; exit 1; }

# destination for each .pkg payload: "pkgfile:repo/path" pairs, one module per line
copy() { local src="$1" dst="$2"; [ -s ".pkg/$src" ] || { echo "missing .pkg/$src" >&2; exit 1; }
         mkdir -p "$(dirname "$dst")"; cp ".pkg/$src" "$dst"; git add -f "$dst"; }

apply_fix() {
  case "$1" in
    01) copy fix01.admin.page.js web/app/admin/page.js
        MSG='fix(01): verify the session in the admin page, not only in middleware' ;;
    02) copy fix02.Caddyfile Caddyfile
        MSG='fix(02): stop serving the checkout .git directory' ;;
    03) copy fix03.compose.yaml compose.yaml
        MSG='fix(03): drop the anonymous download policy on the uploads bucket' ;;
    04) copy fix04.checkout.route.js web/app/api/checkout/route.js
        MSG='fix(04): charge the catalogue price, ignore the posted amount' ;;
    05) copy fix05.ratelimit.js web/lib/ratelimit.js
        copy fix05.login.route.js web/app/api/login/route.js
        MSG='fix(05): rate limit and lock out login per address and per account' ;;
    06) copy fix06.compose.yaml compose.yaml
        MSG='fix(06): stop publishing the postgres port on the LAN' ;;
    07) copy fix07.page.js web/app/page.js
        copy fix07.nginx.conf attacker/nginx.conf
        MSG='fix(07): pin the third-party tracker with subresource integrity' ;;
    08) copy fix08.env .env
        copy fix08.compose.yaml compose.yaml
        copy fix08.Dockerfile Dockerfile
        MSG='fix(08): replace the dictionary JWT secret with a 64-char value' ;;
    09) copy fix09.callback.route.js web/app/api/oauth/callback/route.js
        MSG='fix(09): retire the password on an unconfirmed squatted row, pick deterministically' ;;
    10) copy fix10.Caddyfile Caddyfile
        copy fix10.page.js web/app/page.js
        MSG='fix(10): answer the advertised legacy host from the shop, drop the dangling link' ;;
    11) copy fix11.import.route.js web/app/api/import/route.js
        MSG='fix(11): allowlist, scheme-check and time-bound the import fetch' ;;
    12) copy fix12.forgot.route.js web/app/api/forgot/route.js
        MSG='fix(12): build the reset link from a configured origin, not the Host header' ;;
    13) copy fix13.next.config.mjs web/next.config.mjs
        MSG='fix(13): strip sourcesContent from production browser source maps' ;;
    14) copy fix14.next.config.mjs web/next.config.mjs
        MSG='fix(14): set X-Frame-Options and CSP frame-ancestors' ;;
    15) copy fix15.out.route.js web/app/out/route.js
        MSG='fix(15): allowlist the redirect target, fall back to the shop root' ;;
    16) copy fix16.forgot.route.js web/app/api/forgot/route.js
        copy fix16.login.route.js web/app/api/login/route.js
        copy fix16.signup.route.js web/app/api/signup/route.js
        MSG='fix(16): one response shape across forgot, login and signup' ;;
    17) copy fix17.search.route.js web/app/api/search/route.js
        copy fix17.searchSort.js web/lib/searchSort.js
        copy fix17.search.page.js web/app/search/page.js
        MSG='fix(17): bind the search value and allowlist the sort column, both call sites' ;;
    18) copy fix18.orders.route.js web/app/api/orders/route.js
        copy fix18.order.page.js 'web/app/order/[id]/page.js'
        copy fix18.orders.page.js web/app/orders/page.js
        MSG='fix(18): scope every orders query by the session, api and pages' ;;
    19) copy fix19.esc.js web/lib/esc.js
        copy fix19.product.page.js 'web/app/product/[id]/page.js'
        MSG='fix(19): complete the escaper and escape the review body at the sink' ;;
    20) copy fix20.cart.js web/lib/cart.js
        copy fix20.cart.route.js web/app/api/cart/route.js
        copy fix20.promo.route.js web/app/api/cart/promo/route.js
        MSG='fix(20): validate quantity at the boundary and assign the promo from a table' ;;
    *) echo "unknown module $1" >&2; exit 1 ;;
  esac
}

sel=("$@"); [ ${#sel[@]} -gt 0 ] || sel=($(seq -w 1 20))
for n in "${sel[@]}"; do
  git checkout -B "fix/$n" main >/dev/null
  MSG=''
  apply_fix "$n"
  git commit -q -m "$MSG"
  echo "built fix/$n  ($(git rev-list --count main..fix/$n) commit, $(git diff --stat main..fix/$n | tail -1 | sed 's/^ *//'))"
  git checkout -q main
done
echo 'done; fix branches rebuilt from main + .pkg'
