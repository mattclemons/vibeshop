# Module 10: dangling advertised host

- Family: The pipeline boundary

## The flaw
The footer links legacy.vibeshop.test, which resolves to the box and is served by nobody, so the catch-all hands that Host to the attacker container.

## Why it happens
A name was advertised and never served, and the catch-all forwards unknown hosts to whoever is listening.

## The fix
Answer the advertised host from the shop (a @legacy handle to the app) and drop the dangling footer link.

Files changed on `fix/10`: `Caddyfile`, `web/app/page.js`.

## Options rejected
Only removing the link: the name still resolves and the catch-all still answers it; both the link and the routing must change.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/10` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/10` (every PASS).
- For a browser module, the before/after screen described in post 2.
