import { q } from '../../../lib/db';
import { sha256 } from '../../../lib/auth';

// no confirmation mail, no uniqueness check on email: two rows can share an address (module 12)
export async function POST(req) {
  const { email, password } = await req.json();

  const onFile = await q('SELECT id FROM users WHERE email = $1 LIMIT 1', [email]);

  const r = await q(
    'INSERT INTO users (email, password_hash, role, email_confirmed) VALUES ($1, $2, $3, $4) RETURNING id, email, email_confirmed',
    [email, sha256(password), 'customer', false]
  );

  if (onFile.rows.length) {
    // naive: announces that the address is already on file, and still lets a second account in
    return Response.json({ ok: true, user: r.rows[0], note: 'address already on file, signed you up anyway' });
  }

  return Response.json({ ok: true, user: r.rows[0], note: 'email not verified yet' });
}
