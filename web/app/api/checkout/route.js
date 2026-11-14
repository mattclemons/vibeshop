import { q } from '../../../lib/db';
import { charge } from '../../../lib/stripe';
import { getSession } from '../../../lib/auth';

// the amount is whatever the client says it is. the product price is never consulted.
export async function POST(req) {
  const ct = req.headers.get('content-type') || '';
  let body;
  if (ct.includes('application/json')) {
    body = await req.json();
  } else {
    body = Object.fromEntries(new URLSearchParams(await req.text()));
  }

  const productId = Number(body.productId);
  const amount = Number(body.amount);

  // prep for module 18: stamp the owner. logged-out checkouts get null, which the orders routes never
  // think about again on main.
  const session = await getSession(req);
  const r = await q(
    'INSERT INTO orders (product_id, user_id, amount, status) VALUES ($1, $2, $3, $4) RETURNING *',
    [productId, session ? session.sub : null, amount, 'paid']
  );

  const paid = await charge({ amount });

  if (body.redirect || req.nextUrl.searchParams.has('redirect')) {
    return Response.redirect(new URL('/order/' + r.rows[0].id, 'http://' + req.headers.get('host')), 303);
  }
  return Response.json({ ok: true, charged_cents: amount, charge: paid.id, order: r.rows[0] });
}
