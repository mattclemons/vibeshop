# Module 19: cross-site scripting

- Family: Half-learned concepts

## The flaw
A review is rendered with dangerouslySetInnerHTML and no escaping, so a review is markup for every visitor. The search term goes into an attribute through an escaper that handles < and > and not the quote.

## Why it happens
The escaper handled the part everyone remembers (tags) and not the part that matters in a quoted attribute (the quote); and the review sink had no escaping at all.

## The fix
Complete the escaper (&, <, >, ", ') and escape the review body at the sink.

Files changed on `fix/19`: `web/lib/esc.js`, `web/app/product/[id]/page.js`.

## Options rejected
Switching the review to React text rendering: correct, but the lab keeps the raw-HTML sink to show escaping at the sink; the attribute escaper also had to be completed.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/19` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/19` (every PASS).
- For a browser module, the before/after screen described in post 2.
