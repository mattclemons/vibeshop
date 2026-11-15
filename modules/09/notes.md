# Module 09: oauth account collision

- Family: State discipline

## The flaw
Signup leaves the address unconfirmed, and the provider callback links into any unconfirmed row with that address, so whoever signs up first keeps a working password on the victim's account.

## Why it happens
Linking by address is reasonable; the semantic, trusting an unconfirmed local password after a verified provider login, is the bug.

## The fix
Link by address regardless of confirmation, pick the row deterministically, and retire the password (NULL) only when the row was never confirmed.

Files changed on `fix/09`: `web/app/api/oauth/callback/route.js`.

## Options rejected
Blocking duplicate emails at signup: a good idea on its own, but it does not fix an existing squatted row, and the provider-merge semantic is the real defect.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/09` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/09` (every PASS).
- For a browser module, the before/after screen described in post 2.
