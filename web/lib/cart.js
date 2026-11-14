import { cookies } from 'next/headers';
import { q } from './db';

// module 20: the cart. it does the arithmetic on the server, which reads as careful, and it does the
// arithmetic on whatever it was handed, which is the flaw.
//
//   qty arrives from a form or a query string as text and goes into a numeric column unvalidated
//   the promo code is a counter that increments, so calling the endpoint twice discounts twice
//
// nothing here takes an amount from the client. module 4 is the client's price; this is the client's maths.

const NEW = () => globalThis.crypto?.randomUUID?.() || 'c' + Math.random().toString(36).slice(2);

// the cart is identified by a cookie, so a shop works before anyone logs in
export async function cartId() {
  const jar = await cookies();
  let id = jar.get('cart_id')?.value;
  if (!id) {
    id = NEW();
    jar.set('cart_id', id, { path: '/', httpOnly: true, sameSite: 'lax' });
  }
  return id;
}

export async function cartState(id) {
  const lines = (
    await q(
      `SELECT c.product_id, c.qty, p.name, p.price_cents, c.qty * p.price_cents AS line_cents
         FROM carts c JOIN products p ON p.id = c.product_id
        WHERE c.cart_id = $1
        ORDER BY c.product_id`,
      [id]
    )
  ).rows;

  const promo = (await q('SELECT code, discount FROM cart_promos WHERE cart_id = $1', [id])).rows[0] || null;

  const subtotal = lines.reduce((s, l) => s + Number(l.line_cents), 0);
  const total = Math.round(subtotal * (1 - Number(promo?.discount || 0)));

  return { cart_id: id, lines, subtotal, promo, total };
}

export async function addLine(id, productId, qtyRaw) {
  await q(
    `INSERT INTO carts (cart_id, product_id, qty) VALUES ($1, $2, $3)
       ON CONFLICT (cart_id, product_id) DO UPDATE SET qty = excluded.qty`,
    [id, productId, qtyRaw]
  );
  return cartState(id);
}

// the coupon. discount accumulates instead of being set, so the tenth click is a tenth discount
export async function applyPromo(id, code) {
  await q(
    `INSERT INTO cart_promos (cart_id, code, discount) VALUES ($1, $2, 0.1)
       ON CONFLICT (cart_id) DO UPDATE SET code = excluded.code, discount = cart_promos.discount + 0.1`,
    [id, code]
  );
  return cartState(id);
}

export async function emptyCart(id) {
  await q('DELETE FROM carts WHERE cart_id = $1', [id]);
  await q('DELETE FROM cart_promos WHERE cart_id = $1', [id]);
}
