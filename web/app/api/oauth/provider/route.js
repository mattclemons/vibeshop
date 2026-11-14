import crypto from 'crypto';
import { origin } from '../../../../lib/origin';

// stub provider. canned profile keyed by the email in the query. no real google.
export async function GET(req) {
  const email = req.nextUrl.searchParams.get('email');
  if (!email) return Response.json({ error: 'email required' }, { status: 400 });

  const sub = 'google-oauth2|' + crypto.createHash('sha1').update(email).digest('hex').slice(0, 16);
  const profile = { sub, email, name: email.split('@')[0], email_verified: true };

  const back = req.nextUrl.searchParams.get('redirect_uri') || '/api/oauth/callback';
  const url = new URL(back, origin(req));
  url.searchParams.set('code', email);
  url.searchParams.set('sub', sub);

  return Response.redirect(url, 302);
}
