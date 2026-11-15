# Module 04: price tampering

- Family: Trusting the client

## The flaw
The checkout charges the amount in the posted form instead of looking the product up, so the client sets the price.

## Why it happens
The product page already knows the price, so sending it looks helpful rather than risky.

## The fix
Look the product up and charge price_cents; report the posted amount back but never charge it.

Files changed on `fix/04`: `web/app/api/checkout/route.js`.

## Options rejected
Validating that amount matches the price: the client should not send a price at all; recompute from the id.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/04` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/04` (every PASS).
- For a browser module, the before/after screen described in post 2.
