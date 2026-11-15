# Module 16: email enumeration

- Family: Disclosure

## The flaw
Signup, login and reset each answer differently for a known and an unknown address, so the responses are an oracle for who has an account.

## Why it happens
Each handler says the locally true thing (no account, wrong password, already on file), and the differences add up to an oracle.

## The fix
One response shape across forgot, login and signup, for known and unknown addresses alike.

Files changed on `fix/16`: `web/app/api/forgot/route.js`, `web/app/api/login/route.js`, `web/app/api/signup/route.js`.

## Options rejected
Timing equalisation only: the bodies and status codes differ here, so the fix is response shape; constant-time comparison is a separate concern.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/16` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/16` (every PASS).
- For a browser module, the before/after screen described in post 2.
