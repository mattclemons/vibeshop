import { q } from '../../../lib/db';
import { sha256 } from '../../../lib/auth';

// Same body for a new address and one already on file.
export async function POST(req) {
  const { email, password } = await req.json();

  await q(
    'INSERT INTO users (email, password_hash, role, email_confirmed) VALUES ($1, $2, $3, $4) RETURNING id',
    [email, sha256(password), 'customer', false]
  );

  return Response.json({ ok: true, note: 'Check your email to confirm your account.' });
}
