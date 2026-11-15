# Module 15: open redirect

- Family: The pipeline boundary

## The flaw
/out?to= bounces anywhere with no allowlist, so a phishing page under any name looks like the shop's own login.

## Why it happens
Following the parameter is what an outbound link is for.

## The fix
Honour a host-relative path and an absolute URL only if it points at the shop; everything else falls back to the shop root.

Files changed on `fix/15`: `web/app/out/route.js`.

## Options rejected
A denylist of known-bad hosts: trivially bypassed. Allowlist the shop and treat everything else as off-site.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/15` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/15` (every PASS).
- For a browser module, the before/after screen described in post 2.
