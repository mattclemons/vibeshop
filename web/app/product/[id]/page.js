import { q } from '../../../lib/db';
import { esc } from '../../../lib/esc';

export const dynamic = 'force-dynamic';

export default async function Product({ params, searchParams }) {
  const { id } = await params;
  const { q: term } = await searchParams;
  const product = (await q('SELECT * FROM products WHERE id = $1', [id])).rows[0];

  if (!product) return <main><p>no such product</p></main>;

  const reviews = (await q('SELECT * FROM reviews WHERE product_id = $1 ORDER BY id', [id])).rows;

  return (
    <main>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
      <p>price: {(product.price_cents / 100).toFixed(2)}</p>

      {/* the amount travels with the form and the server charges it verbatim (module 4) */}
      <form method="POST" action="/api/checkout?redirect=1">
        <input type="hidden" name="productId" value={product.id} />
        <input type="hidden" name="amount" value={product.price_cents} />
        <button>buy</button>
      </form>

      {/* module 20: a quantity the customer picks, handed to the cart as text and unvalidated */}
      <form method="POST" action={`/api/cart?product_id=${product.id}`}>
        <input name="qty" defaultValue="1" size={3} />
        <button>add to cart</button>
      </form>

      {/* module 19, sink one: a hand-rolled escaper used inside a raw html string. escaping < and > is
          right for element text and useless in a quoted attribute: one " ends the value and the rest of
          the payload becomes attributes. the text half of the same line is safe, which is the trap. */}
      <div
        dangerouslySetInnerHTML={{
          __html: `<b>you searched for:</b> <input data-term="${esc(term || '')}" readonly /> <i>${esc(
            term || ''
          )}</i>`,
        }}
      />
      <form action={`/product/${id}`}>
        <input name="q" placeholder="search this page" defaultValue={term || ''} />
        <button>go</button>
      </form>

      <h2>reviews</h2>
      <form method="POST" action={`/api/reviews?product_id=${id}`}>
        <input name="author" placeholder="your name" />
        <textarea name="body" placeholder="say something" rows={2} />
        <button>post review</button>
      </form>

      <ul id="reviews">
        {reviews.map((r) => (
          <li key={r.id}>
            <b>{r.author}</b>{' '}
            {/* module 19, sink two: raw html, so a review can carry tags, and no escaping at all */}
            <span dangerouslySetInnerHTML={{ __html: r.body }} />
          </li>
        ))}
      </ul>

      <p>
        promo: <code>VIBE10</code> via the <a href="/cart">cart</a>
      </p>
      <pre>{JSON.stringify(product, null, 1)}</pre>
    </main>
  );
}
