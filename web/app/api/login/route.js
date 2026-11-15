import { q } from '../../../lib/db';
import { loginAs, sha256 } from '../../../lib/auth';
import { check, clear } from '../../../lib/ratelimit';

export async function POST(req) {
  const { email, password } = await req.json();
  const address = req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip') || 'local';

  const rl = check(email, address);
  if (rl.blocked) {
    return Response.json(
      { error: 'too many attempts, slow down' },
      { status: 429, headers: { 'retry-after': String(rl.retry) } }
    );
  }

  const found = await q('SELECT * FROM users WHERE email = $1 LIMIT 1', [email]);
  if (found.rows.length === 0) {
    return Response.json({ error: 'no account with that email' }, { status: 404 });
  }

  const user = found.rows[0];
  if (user.password_hash !== sha256(password)) {
    return Response.json({ error: 'wrong password for ' + email }, { status: 401 });
  }

  clear(email);
  const token = await loginAs(user);
  const res = Response.json({ ok: true, id: user.id, email: user.email, role: user.role, token });
  res.headers.append('set-cookie', 'vs_session=' + token + '; Path=/; HttpOnly; SameSite=Lax');
  return res;
}
