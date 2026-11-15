# Module 17: sql injection in the search box

- Family: Half-learned concepts

## The flaw
The search value is interpolated with a template literal, and the ORDER BY column is concatenated too, which is the half a developer who knows about binding still gets wrong. The route echoes the SQL it built.

## Why it happens
Binding was learned for values; identifiers cannot be bound, so the column was concatenated, and the value was too.

## The fix
Bind the value (ILIKE $1) and allowlist the sort column, in both call sites (the API route and the page).

Files changed on `fix/17`: `web/app/api/search/route.js`, `web/lib/searchSort.js`, `web/app/search/page.js`.

## Options rejected
Escaping quotes by hand: the ORDER BY identifier still needs an allowlist, and hand-escaping is the half-fix that leaves the second sink open.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/17` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/17` (every PASS).
- For a browser module, the before/after screen described in post 2.
