# Module 14: clickjacking

- Family: The pipeline boundary

## The flaw
No X-Frame-Options and no CSP frame-ancestors anywhere, so any origin can frame the shop and overlay the buy button.

## Why it happens
The header gets added when someone asks about embedding.

## The fix
Set X-Frame-Options: DENY and Content-Security-Policy: frame-ancestors 'none' for every path.

Files changed on `fix/14`: `web/next.config.mjs`.

## Options rejected
Relying on X-Frame-Options alone: fine for old browsers, but frame-ancestors is the current control; set both.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/14` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/14` (every PASS).
- For a browser module, the before/after screen described in post 2.
