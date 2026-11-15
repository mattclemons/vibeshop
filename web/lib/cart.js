import { cookies } from 'next/headers';
import { q } from './db';

const NEW = () => globalThis.crypto?.randomUUID?.() || 'c' + Math.random().toString(36).slice(2);

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

// validate at the boundary: a quantity is a positive integer, and nothing else reaches the column
export function validateQty(raw) {
  const s = String(raw).trim();
  if (!/^\d+$/.test(s) || Number(s) < 1) {
    const e = new Error('invalid quantity: ' + raw);
    e.status = 400;
    e.value = raw;
    throw e;
  }
  return Number(s);
}

export async function addLine(id, productId, qtyRaw) {
  const qty = validateQty(qtyRaw);
  await q(
    `INSERT INTO carts (cart_id, product_id, qty) VALUES ($1, $2, $3)
       ON CONFLICT (cart_id, product_id) DO UPDATE SET qty = excluded.qty`,
    [id, productId, qty]
  );
  return cartState(id);
}

// assign the discount from a rate table, so calling twice is the same as calling once
const RATES = { VIBE10: 0.1 };
export async function applyPromo(id, code) {
  const discount = RATES[code] ?? 0;
  await q(
    `INSERT INTO cart_promos (cart_id, code, discount) VALUES ($1, $2, $3)
       ON CONFLICT (cart_id) DO UPDATE SET code = excluded.code, discount = excluded.discount`,
    [id, code, discount]
  );
  return cartState(id);
}

export async function emptyCart(id) {
  await q('DELETE FROM carts WHERE cart_id = $1', [id]);
  await q('DELETE FROM cart_promos WHERE cart_id = $1', [id]);
}
