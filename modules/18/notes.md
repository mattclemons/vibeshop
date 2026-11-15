# Module 18: idor / bola in the orders api

- Family: Computing but not gating

## The flaw
Every route calls getSession, returns 401 without one, and never asks whether the row belongs to the caller. The response even computes mine and hands the row over anyway.

## Why it happens
Authentication is visible and felt like enough; authorisation (the owner predicate) was never added.

## The fix
AND user_id = $me on the read, the list and the update, in the route and both pages; the receipt page 404s for a non-owner and redirects when logged out.

Files changed on `fix/18`: `web/app/api/orders/route.js`, `web/app/order/[id]/page.js`, `web/app/orders/page.js`.

## Options rejected
Checking ownership in the handler after the query returns: it leaks existence via timing and still fetches the row; scope the query itself so it fails closed.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/18` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/18` (every PASS).
- For a browser module, the before/after screen described in post 2.
