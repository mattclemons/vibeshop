# Module 11: ssrf from the import endpoint

- Family: The pipeline boundary

## The flaw
/api/import?url= fetches server side, from inside the compose network, with no allowlist.

## Why it happens
An outbound import is what the feature is for, so following the parameter looks correct.

## The fix
An allowlist of the hosts the feature needs, a scheme check and a timeout. An off-allowlist host is a 400 that names the allowlist.

Files changed on `fix/11`: `web/app/api/import/route.js`.

## Options rejected
A denylist of internal ranges: easy to bypass with DNS and redirects. This lab's fix is an allowlist; note that a production fix would also drop the metadata host, which this teaching fix keeps to match the walkthrough.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/11` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/11` (every PASS).
- For a browser module, the before/after screen described in post 2.
