import { q } from '../../../lib/db';
import { getSession } from '../../../lib/auth';

// Authenticated and authorised: every query is scoped to the caller's id, on reads and writes.
export async function GET(req) {
  const session = await getSession(req);
  if (!session) return Response.json({ error: 'log in first' }, { status: 401 });
  const me = Number(session.sub);
  const id = req.nextUrl.searchParams.get('id');

  if (id) {
    const r = await q('SELECT * FROM orders WHERE id = $1 AND user_id = $2', [id, me]);
    if (!r.rows.length) return Response.json({ error: 'no such order' }, { status: 404 });
    return Response.json({ me, order: r.rows[0], mine: true });
  }

  const all = await q('SELECT * FROM orders WHERE user_id = $1 ORDER BY id', [me]);
  return Response.json({ me, count: all.rows.length, orders: all.rows.map((o) => ({ ...o, mine: true })) });
}

export async function POST(req) {
  const session = await getSession(req);
  if (!session) return Response.json({ error: 'log in first' }, { status: 401 });
  const me = Number(session.sub);
  const id = req.nextUrl.searchParams.get('id');

  const r = await q("UPDATE orders SET status = 'cancelled' WHERE id = $1 AND user_id = $2 RETURNING *", [id, me]);
  if (!r.rows.length) return Response.json({ error: 'no such order' }, { status: 404 });
  return Response.json({ me, order: r.rows[0] });
}
