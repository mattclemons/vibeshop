import crypto from 'crypto';
import { q } from '../../../lib/db';
import { sendMail } from '../../../lib/mail';

// One response shape whether or not the address is on file.
export async function POST(req) {
  const ct = req.headers.get('content-type') || '';
  const body = ct.includes('json') ? await req.json() : Object.fromEntries(new URLSearchParams(await req.text()));
  const email = body.email;

  const found = await q('SELECT * FROM users WHERE email = $1 LIMIT 1', [email]);
  if (found.rows.length) {
    const token = crypto.randomUUID().replace(/-/g, '');
    await q('UPDATE users SET reset_token = $1 WHERE id = $2', [token, found.rows[0].id]);
    const host = req.headers.get('host');
    await sendMail({
      to: email,
      subject: 'Reset your VibeShop password',
      text: 'Reset your password: http://' + host + '/reset?token=' + token,
    });
  }
  return Response.json({ ok: true, message: 'If that account exists, a reset link has been sent.' });
}

export async function GET(req) {
  const email = req.nextUrl.searchParams.get('email') || 'maya@vibeshop.test';
  return POST({
    headers: new Headers({ 'content-type': 'application/json', host: req.headers.get('host') || '' }),
    json: async () => ({ email }),
  });
}
