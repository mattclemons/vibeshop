import { q } from '../../../lib/db';
import { loginAs, sha256 } from '../../../lib/auth';

export async function POST(req) {
  const { email, password } = await req.json();

  const found = await q('SELECT * FROM users WHERE email = $1 LIMIT 1', [email]);
  if (found.rows.length === 0) {
    // distinct body #1
    return Response.json({ error: 'no account with that email' }, { status: 404 });
  }

  const user = found.rows[0];
  if (user.password_hash !== sha256(password)) {
    // distinct body #2
    return Response.json({ error: 'wrong password for ' + email }, { status: 401 });
  }

  const token = await loginAs(user);
  const res = Response.json({ ok: true, id: user.id, email: user.email, role: user.role, token });
  res.headers.append(
    'set-cookie',
    'vs_session=' + token + '; Path=/; HttpOnly; SameSite=Lax'
  );
  return res;
}
