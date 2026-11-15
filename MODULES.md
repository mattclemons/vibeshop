# The twenty modules

The companion post (post 1) describes the app. The attack post (post 2) attacks it. This directory
tree is the reconstruction of the twenty numbered exploit/test/fix modules post 2 documents but that
the generator did not ship.

## Contract

- `exploits/NN/run.sh`  exits 0 while the flaw is present (on `main`), 1 once fixed.
- `tests/NN/test.sh`    asserts the fixed behaviour: exit 1 on `main`, 0 on `fix/NN`.
- `exploits/NN/README.md`  the write-up (paste real output from your VM).
- `modules/NN/notes.md`    flaw, why, fix, options rejected.
- `.pkg/fixNN.*`           the fix payload, committed on `main`, applied on branch `fix/NN`.

Both scripts source `scripts/env.sh`; the test helper `fail()` exits on the first failing assertion,
because the first failing assertion is the finding.

## Index

| NN | flaw | fix file(s) |
|----|------|-------------|
| 01 | middleware auth bypass | web/app/admin/page.js |
| 02 | .git exposure | Caddyfile |
| 03 | open bucket | compose.yaml |
| 04 | price tampering | web/app/api/checkout/route.js |
| 05 | no rate limit, no lockout | web/lib/ratelimit.js, web/app/api/login/route.js |
| 06 | open database | compose.yaml |
| 07 | third party script, no sri | web/app/page.js, attacker/nginx.conf |
| 08 | weak jwt secret | .env, compose.yaml, Dockerfile |
| 09 | oauth account collision | web/app/api/oauth/callback/route.js |
| 10 | dangling advertised host | Caddyfile, web/app/page.js |
| 11 | ssrf from the import endpoint | web/app/api/import/route.js |
| 12 | host header injection | web/app/api/forgot/route.js |
| 13 | source maps published | web/next.config.mjs |
| 14 | clickjacking | web/next.config.mjs |
| 15 | open redirect | web/app/out/route.js |
| 16 | email enumeration | web/app/api/forgot,login,signup/route.js |
| 17 | sql injection in the search box | web/app/api/search/route.js, web/lib/searchSort.js, web/app/search/page.js |
| 18 | idor / bola in the orders api | web/app/api/orders/route.js, web/app/order/[id]/page.js, web/app/orders/page.js |
| 19 | cross-site scripting | web/lib/esc.js, web/app/product/[id]/page.js |
| 20 | business logic abuse in the cart | web/lib/cart.js, web/app/api/cart/route.js, web/app/api/cart/promo/route.js |

## Branches

`main` is always flawed and carries every `.pkg/fixNN.*`. Each `fix/NN` is exactly `main` plus that one
fix. Rebuild them from `main`:

    bash scripts/make-fix-branches.sh            # all twenty
    bash scripts/make-fix-branches.sh 04 18 20   # a subset

## Audit

    make reset
    bash scripts/audit.sh --modules              # on main: every exploit 0, every test 1
    bash scripts/audit.sh --branches             # plus every fix/NN: test 0, exploit 1, back to main
    bash scripts/audit.sh --branches 06 07       # a subset

`--branches` rebuilds the stack on each branch (`make reset`), because several fixes are build or infra
changes (Caddyfile, compose, Dockerfile, next.config, nginx), not just code a reseed would pick up.

Modules 14 and 19 have a browser step, module 2 walks the repository over HTTP, module 6 needs a
container on its own network, and the rest are curl and a pipe.
