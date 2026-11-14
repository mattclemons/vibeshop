import { NextResponse } from 'next/server';
import { q } from '../../../../lib/db';
import { loginAs } from '../../../../lib/auth';
import { origin } from '../../../../lib/origin';

// Signup never confirms the address. So an existing unconfirmed row with the same email is
// treated as "the same person" and the provider identity is merged straight into it.
export async function GET(req) {
  const email = req.nextUrl.searchParams.get('code') || req.nextUrl.searchParams.get('email');
  const sub = req.nextUrl.searchParams.get('sub') || 'google-oauth2|unknown';

  if (!email) return Response.json({ error: 'no code' }, { status: 400 });

  const existing = await q(
    'SELECT * FROM users WHERE email = $1 AND email_confirmed = false ORDER BY id LIMIT 1',
    [email]
  );

  let user;
  let merged = false;

  if (existing.rows.length) {
    merged = true;
    user = (
      await q(
        'UPDATE users SET oauth_sub = $1, oauth_provider = $2, email_confirmed = true WHERE id = $3 RETURNING *',
        [sub, 'stub', existing.rows[0].id]
      )
    ).rows[0];
  } else {
    user = (
      await q(
        'INSERT INTO users (email, role, email_confirmed, oauth_sub, oauth_provider) VALUES ($1, $2, true, $3, $4) RETURNING *',
        [email, 'customer', sub, 'stub']
      )
    ).rows[0];
  }

  const token = await loginAs(user);
  // NextResponse, not Response.redirect: the latter's headers are immutable and append() throws
  const res = NextResponse.redirect(new URL('/', origin(req)), 302);
  res.headers.append(
    'set-cookie',
    'vs_session=' + token + '; Path=/; HttpOnly; SameSite=Lax'
  );
  res.headers.append('x-oauth-merged', String(merged));
  res.headers.append('x-oauth-user-id', String(user.id));
  return res;
}
