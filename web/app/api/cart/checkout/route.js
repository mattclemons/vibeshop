import { q } from '../../../../lib/db';
import { getSession } from '../../../../lib/auth';
import { cartId, cartState, emptyCart } from '../../../../lib/cart';

// module 20: the shop charges the cart's own total. it recomputes the arithmetic on the server, and the
// arithmetic was done from quantities nobody validated, so a negative line or a stacked coupon produces an
// order the shop pays for.
//
// note there is no amount in the request. that is module 4's flaw, this is the other one.
export async function POST(req) {
  const id = await cartId();
  const state = await cartState(id);

  if (!state.lines.length) return Response.json({ error: 'cart is empty' }, { status: 400 });

  const session = await getSession(req);
  const r = await q(
    'INSERT INTO orders (product_id, user_id, amount, status) VALUES ($1, $2, $3, $4) RETURNING *',
    [state.lines[0].product_id, session ? Number(session.sub) : null, state.total, 'paid']
  );

  await emptyCart(id);

  const host = req.headers.get('host');
  if (req.nextUrl.searchParams.get('redirect')) {
    return Response.redirect(new URL('/orders', `http://${host}`), 303);
  }
  return Response.json({ ok: true, charged: state.total, lines: state.lines, order: r.rows[0] });
}
