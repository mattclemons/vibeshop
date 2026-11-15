# Module 05: no rate limit, no lockout

- Family: Leaving the defaults alone

## The flaw
/api/login accepts attempts as fast as the network allows: no 429, no lockout, no counter.

## Why it happens
Limits get added when someone asks, not by default. The happy path works without them.

## The fix
A sliding-window counter per address and per account; a 429 with Retry-After once the window trips, cleared on a successful login.

Files changed on `fix/05`: `web/lib/ratelimit.js`, `web/app/api/login/route.js`.

## Options rejected
A single global counter: it would lock every user out together. Scope the limit to the account and the address.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/05` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/05` (every PASS).
- For a browser module, the before/after screen described in post 2.
