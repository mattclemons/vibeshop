# Module 03: open bucket

- Family: Leaving the defaults alone

## The flaw
The MinIO uploads bucket carries the anonymous download policy, so the fixture identity documents are world-readable.

## Why it happens
The policy was set so an <img> tag works without signing. Convenience became exposure.

## The fix
Drop the anonymous policy (mc anonymous set none) and sign URLs. Anonymous returns 403 AccessDenied while signed requests still return 200.

Files changed on `fix/03`: `compose.yaml`.

## Options rejected
Deleting the bucket: the app still needs it; the fix is the policy, not the data.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/03` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/03` (every PASS).
- For a browser module, the before/after screen described in post 2.
