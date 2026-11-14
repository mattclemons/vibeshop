import { createHash } from 'crypto';
import { verifyToken, signToken } from './jwt';
import { q } from './db';

export const sha256 = (s) => createHash('sha256').update(s).digest('hex');

// verified on every request that asks for a session
export async function getSession(req) {
  const token = req.cookies.get('vs_session')?.value;
  if (!token) return null;
  return verifyToken(token);
}

export async function loginAs(user) {
  return signToken({ sub: user.id, email: user.email, role: user.role });
}

export async function userById(id) {
  const r = await q('SELECT * FROM users WHERE id = $1', [id]);
  return r.rows[0] || null;
}
