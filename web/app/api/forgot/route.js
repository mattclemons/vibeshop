import crypto from 'crypto';
import { q } from '../../../lib/db';
import { sendMail } from '../../../lib/mail';

// The link is built from a configured origin, never from the request Host.
const SITE_ORIGIN = process.env.SITE_ORIGIN || 'http://vibeshop.test';

export async function POST(req) {
  const ct = req.headers.get('content-type') || '';
  const body = ct.includes('json') ? await req.json() : Object.fromEntries(new URLSearchParams(await req.text()));
  const email = body.email;

  const found = await q('SELECT * FROM users WHERE email = $1 LIMIT 1', [email]);
  if (found.rows.length === 0) {
    return Response.json({ error: 'no account with that email' }, { status: 404 });
  }

  const token = crypto.randomUUID().replace(/-/g, '');
  await q('UPDATE users SET reset_token = $1 WHERE id = $2', [token, found.rows[0].id]);

  const link = SITE_ORIGIN + '/reset?token=' + token;
  await sendMail({ to: email, subject: 'Reset your VibeShop password', text: 'Reset your password: ' + link });
  return Response.json({ ok: true, link, origin: SITE_ORIGIN });
}

export async function GET(req) {
  const email = req.nextUrl.searchParams.get('email') || 'maya@vibeshop.test';
  return POST({ headers: new Headers({ 'content-type': 'application/json' }), json: async () => ({ email }) });
}
