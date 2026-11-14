import { q } from '../../../lib/db';
import { sha256 } from '../../../lib/auth';

export async function POST(req) {
  const { token, password } = await req.json();

  const found = await q('SELECT * FROM users WHERE reset_token = $1', [token]);
  if (found.rows.length === 0) return Response.json({ error: 'bad token' }, { status: 400 });

  await q('UPDATE users SET password_hash = $1 WHERE id = $2', [sha256(password), found.rows[0].id]);
  return Response.json({ ok: true, email: found.rows[0].email });
}
