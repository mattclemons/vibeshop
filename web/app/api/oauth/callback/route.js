import { NextResponse } from 'next/server';
import { q } from '../../../../lib/db';
import { loginAs } from '../../../../lib/auth';
import { origin } from '../../../../lib/origin';

// Link by address regardless of confirmation, pick the row deterministically, and retire the
// password only when the row was never confirmed. A confirmed account keeps its password.
export async function GET(req) {
  const email = req.nextUrl.searchParams.get('code') || req.nextUrl.searchParams.get('email');
  const sub = req.nextUrl.searchParams.get('sub') || 'google-oauth2|unknown';
  if (!email) return Response.json({ error: 'no code' }, { status: 400 });

  const existing = await q('SELECT * FROM users WHERE email = $1 ORDER BY id LIMIT 1', [email]);

  let user;
  let merged = false;
  let retired = false;

  if (existing.rows.length) {
    merged = true;
    const row = existing.rows[0];
    if (row.email_confirmed === false) {
      retired = true;
      user = (
        await q(
          'UPDATE users SET oauth_sub = $1, oauth_provider = $2, email_confirmed = true, password_hash = NULL WHERE id = $3 RETURNING *',
          [sub, 'stub', row.id]
        )
      ).rows[0];
    } else {
      user = (
        await q('UPDATE users SET oauth_sub = $1, oauth_provider = $2 WHERE id = $3 RETURNING *', [sub, 'stub', row.id])
      ).rows[0];
    }
  } else {
    user = (
      await q(
        'INSERT INTO users (email, role, email_confirmed, oauth_sub, oauth_provider) VALUES ($1, $2, true, $3, $4) RETURNING *',
        [email, 'customer', sub, 'stub']
      )
    ).rows[0];
  }

  const token = await loginAs(user);
  const res = NextResponse.redirect(new URL('/', origin(req)), 302);
  res.headers.append('set-cookie', 'vs_session=' + token + '; Path=/; HttpOnly; SameSite=Lax');
  res.headers.append('x-oauth-merged', String(merged));
  res.headers.append('x-oauth-password-retired', String(retired));
  res.headers.append('x-oauth-user-id', String(user.id));
  return res;
}
