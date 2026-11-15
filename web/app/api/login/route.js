import { q } from '../../../lib/db';
import { loginAs, sha256 } from '../../../lib/auth';

// One failure shape whether the email is unknown or the password is wrong.
export async function POST(req) {
  const { email, password } = await req.json();

  const found = await q('SELECT * FROM users WHERE email = $1 LIMIT 1', [email]);
  const user = found.rows[0];
  if (!user || user.password_hash !== sha256(password)) {
    return Response.json({ error: 'invalid email or password' }, { status: 401 });
  }

  const token = await loginAs(user);
  const res = Response.json({ ok: true, id: user.id, email: user.email, role: user.role, token });
  res.headers.append('set-cookie', 'vs_session=' + token + '; Path=/; HttpOnly; SameSite=Lax');
  return res;
}
