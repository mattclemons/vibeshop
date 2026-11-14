import Link from 'next/link';
import { cookies } from 'next/headers';
import { q } from '../../lib/db';
import { cartState } from '../../lib/cart';

export const dynamic = 'force-dynamic';

// the naive cart page: every control posts without javascript, and the page prints the arithmetic it is
// about to charge, so the numbers are visible before anyone checks out.
export default async function Cart() {
  const id = (await cookies()).get('cart_id')?.value || '';
  const state = id ? await cartState(id) : { lines: [], subtotal: 0, promo: null, total: 0 };

  return (
    <main>
      <h1>Your cart</h1>
      {state.lines.length === 0 ? <p>nothing in it yet</p> : null}

      <table>
        <tbody>
          {state.lines.map((l) => (
            <tr key={l.product_id}>
              <td>{l.name}</td>
              <td>
                <form method="POST" action={`/api/cart?product_id=${l.product_id}`}>
                  <input name="qty" defaultValue={l.qty} size={4} />
                  <button>set</button>
                </form>
              </td>
              <td>{l.qty} x {l.price_cents}</td>
              <td>{String(l.line_cents)}</td>
            </tr>
          ))}
        </tbody>
      </table>

      <p>
        subtotal {state.subtotal}
        {state.promo ? ` | promo ${state.promo.code} -${Number(state.promo.discount) * 100}%` : ''}
      </p>
      <p><b>total {state.total}</b></p>

      <form method="POST" action="/api/cart/promo">
        <input name="code" defaultValue="VIBE10" />
        <button>apply promo</button>
      </form>

      <form method="POST" action="/api/cart/checkout?redirect=1">
        <button>check out</button>
      </form>

      <p>
        <Link href="/">home</Link> | add from a <Link href="/product/1">product page</Link> |{' '}
        <Link href="/orders">my orders</Link>
      </p>
      <pre>{JSON.stringify(state, null, 1)}</pre>
    </main>
  );
}
