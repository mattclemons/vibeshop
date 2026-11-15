# Module 01: middleware auth bypass

- Family: Leaving the defaults alone

## The flaw
/admin is gated only by web/middleware.js, and Next's own loop guard makes the middleware skip itself, so the x-middleware-subrequest header walks past the only gate. Five repetitions is the depth here.

## Why it happens
The admin page trusts middleware to be the boundary. Middleware is a convenience, not an authorisation layer, and a framework primitive used as the only gate inherits the framework's bypasses.

## The fix
The admin page verifies the session (and the admin role) itself, so middleware is a cheap early exit rather than the boundary.

Files changed on `fix/01`: `web/app/admin/page.js`.

## Options rejected
Patching Next instead of the app: the version pin is deliberate (see module 13 family), and an app that leans on middleware for authz is wrong even on a patched Next.

## Shots to capture
- The exploit output on `main` (exit 0) and on `fix/01` (exit 1, FIXED).
- The test output on `main` (first FAIL) and on `fix/01` (every PASS).
- For a browser module, the before/after screen described in post 2.
