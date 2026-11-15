import { q } from '../../../lib/db';
import { charge } from '../../../lib/stripe';
import { getSession } from '../../../lib/auth';

// The price is recomputed server-side from the product id. The posted amount is reported back for
// transparency but never charged.
export async function POST(req) {
  const ct = req.headers.get('content-type') || '';
  let body;
  if (ct.includes('application/json')) {
    body = await req.json();
  } else {
    body = Object.fromEntries(new URLSearchParams(await req.text()));
  }

  const productId = Number(body.productId);
  const posted = Number(body.amount);

  const pr = await q('SELECT price_cents FROM products WHERE id = $1', [productId]);
  if (!pr.rows.length) return Response.json({ error: 'no such product' }, { status: 404 });
  const amount = pr.rows[0].price_cents;

  const session = await getSession(req);
  const r = await q(
    'INSERT INTO orders (product_id, user_id, amount, status) VALUES ($1, $2, $3, $4) RETURNING *',
    [productId, session ? session.sub : null, amount, 'paid']
  );

  const paid = await charge({ amount });

  if (body.redirect || req.nextUrl.searchParams.has('redirect')) {
    return Response.redirect(new URL('/order/' + r.rows[0].id, 'http://' + req.headers.get('host')), 303);
  }
  return Response.json({ ok: true, posted_cents: posted, charged_cents: amount, charge: paid.id, order: r.rows[0] });
}
