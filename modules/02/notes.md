# Module 02: .git exposure

- Family: Leaving the defaults alone

## The flaw
Caddy serves /.git/* off the project directory, so the repository is public. The leak is not the current code but the history: an old commit holds a Stripe key no longer in the working tree.

## Why it happens
The deploy directory was published without thinking about what is in it. A served .git is a full clone of history.

## The fix
Delete the handle /.git/* blocks from the Caddyfile. The key stays in history on disk, proving the exposure was the server, not the repo.

Files changed on `fix/02`: `Caddyfile`.

## Options rejected
Rewriting history to purge the key: the exercise is about not serving .git, and in a real incident the leaked key must be rotated regardless.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/02` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/02` (every PASS).
- For a browser module, the before/after screen described in post 2.
