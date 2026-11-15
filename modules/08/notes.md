# Module 08: weak jwt secret

- Family: Leaving the defaults alone

## The flaw
The HS256 secret is a word in the shipped wordlist, so one captured token cracks the key offline and any session can be minted, including for a user with no row.

## Why it happens
A readable word reads well in a config file.

## The fix
A 64-character secret in .env, passed through compose build args and the Dockerfile. The crack returns NOTFOUND.

Files changed on `fix/08`: `.env`, `compose.yaml`, `Dockerfile`.

## Options rejected
Switching to RS256: a larger change than the lab needs; the flaw is secret strength, not the algorithm. Password hashes are still unsalted (crack.py pw) and would be a separate fix.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/08` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/08` (every PASS).
- For a browser module, the before/after screen described in post 2.
