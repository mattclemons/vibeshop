import { q } from '../../../lib/db';
import { getSession } from '../../../lib/auth';

// module 18: every route here checks that you are logged in, and never that the order is yours.
//
//   GET  /api/orders          -> the whole table, presented as "my orders"
//   GET  /api/orders?id=3     -> whatever id you pass, owner unchecked, and me is in the response so
//                                you can watch yours differ from the order's
//   POST /api/orders?id=3     -> cancels whatever id you pass
//
// the session is real, the authorisation is missing. that is BOLA: authenticated, not authorised.
export async function GET(req) {
  const session = await getSession(req);
  if (!session) return Response.json({ error: 'log in first' }, { status: 401 });

  const id = req.nextUrl.searchParams.get('id');

  if (id) {
    const r = await q('SELECT * FROM orders WHERE id = $1', [id]);
    if (!r.rows.length) return Response.json({ error: 'no such order' }, { status: 404 });
    const order = r.rows[0];
    return Response.json({ me: Number(session.sub), order, mine: order.user_id === Number(session.sub) });
  }

  const all = await q('SELECT * FROM orders ORDER BY id');
  return Response.json({
    me: Number(session.sub),
    count: all.rows.length,
    orders: all.rows.map((o) => ({ ...o, mine: o.user_id === Number(session.sub) })),
  });
}

export async function POST(req) {
  const session = await getSession(req);
  if (!session) return Response.json({ error: 'log in first' }, { status: 401 });

  const id = req.nextUrl.searchParams.get('id');
  const r = await q("UPDATE orders SET status = 'cancelled' WHERE id = $1 RETURNING *", [id]);
  if (!r.rows.length) return Response.json({ error: 'no such order' }, { status: 404 });

  return Response.json({ me: Number(session.sub), order: r.rows[0] });
}
