# Module 12: host header injection

- Family: Trusting the client

## The flaw
/api/forgot builds the mailed link from the request Host header, so a reset the attacker triggers mails a link on the attacker's own name.

## Why it happens
The Host is the easiest way to build an absolute URL.

## The fix
Build the link from a configured site origin (SITE_ORIGIN), never from the Host header.

Files changed on `fix/12`: `web/app/api/forgot/route.js`.

## Options rejected
Validating the Host against an allowlist: works, but there is no reason to derive the origin from an attacker-controlled header at all.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/12` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/12` (every PASS).
- For a browser module, the before/after screen described in post 2.
