# Module 06: open database

- Family: Leaving the defaults alone

## The flaw
Postgres is published on the LAN with a password-only pg_hba and no firewall, and the password is in a committed file.

## Why it happens
The port was published so a client could reach it, and nothing narrowed who that client is.

## The fix
Remove the published 5432 mapping. The app reaches postgres on the compose network; nothing on the LAN can.

Files changed on `fix/06`: `compose.yaml`.

## Options rejected
Adding a firewall rule while leaving the port published: defence in depth is good, but the port should not be on the LAN at all.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/06` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/06` (every PASS).
- For a browser module, the before/after screen described in post 2.
