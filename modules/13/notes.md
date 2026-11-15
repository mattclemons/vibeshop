# Module 13: source maps published

- Family: Disclosure

## The flaw
productionBrowserSourceMaps ships the browser build's source maps, with sourcesContent, to production.

## Why it happens
Source maps were enabled to make stack traces useful and never turned off.

## The fix
Keep the maps served and naming the file, but strip sourcesContent (nosources-source-map), so the original source text is gone.

Files changed on `fix/13`: `web/next.config.mjs`.

## Options rejected
Deleting maps entirely: acceptable, but the walkthrough keeps the map and removes only the source text, which is the minimal disclosure fix.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/13` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/13` (every PASS).
- For a browser module, the before/after screen described in post 2.
