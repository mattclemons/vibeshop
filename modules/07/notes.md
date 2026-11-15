# Module 07: third party script, no sri

- Family: The pipeline boundary

## The flaw
The page loads another origin's script over plain HTTP with no integrity and no version, so a swap on that host is silent.

## Why it happens
The CDN snippet was copied and the hash dropped.

## The fix
Add integrity (sha384) and crossorigin to the tag, and Access-Control-Allow-Origin on the host, because SRI needs the cross-origin read.

Files changed on `fix/07`: `web/app/page.js`, `attacker/nginx.conf`.

## Options rejected
Self-hosting the script instead: valid, but the exercise is SRI on a third-party origin.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/07` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/07` (every PASS).
- For a browser module, the before/after screen described in post 2.
