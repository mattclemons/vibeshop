# Module 20: business logic abuse in the cart

- Family: Trusting the client

## The flaw
The cart does arithmetic on a quantity nobody validated, and the promo endpoint adds ten percent every call instead of assigning once.

## Why it happens
The happy path (one mug, one code) is correct, so neither the validation nor the assign-versus-accumulate choice was made.

## The fix
Validate the quantity at the boundary (a positive integer, the offending value quoted back) and assign the promo from a rate table so repeats are idempotent.

Files changed on `fix/20`: `web/lib/cart.js`, `web/app/api/cart/route.js`, `web/app/api/cart/promo/route.js`.

## Options rejected
Clamping a negative quantity to zero: it hides the abuse instead of refusing it. Refuse loudly with the value quoted back.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/20` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/20` (every PASS).
- For a browser module, the before/after screen described in post 2.
