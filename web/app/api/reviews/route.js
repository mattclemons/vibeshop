import { q } from '../../../lib/db';

// module 19: a review is stored exactly as typed and the page renders it as HTML, so whatever a customer
// writes is whatever every other customer's browser parses. no sanitising here, no escaping here.
export async function POST(req) {
  const productId = req.nextUrl.searchParams.get('product_id');

  let author = '';
  let body = '';
  if ((req.headers.get('content-type') || '').includes('application/json')) {
    const j = await req.json();
    author = j.author || '';
    body = j.body || '';
  } else {
    const f = await req.formData();
    author = f.get('author') || '';
    body = f.get('body') || '';
  }
  if (!body) return Response.json({ error: 'body required' }, { status: 400 });

  const r = await q(
    'INSERT INTO reviews (product_id, author, body) VALUES ($1, $2, $3) RETURNING *',
    [productId, author || 'anonymous', body]
  );

  // the form posts without javascript, so answer with a redirect back to the product
  const host = req.headers.get('host');
  return Response.redirect(new URL(`/product/${productId}`, `http://${host}`), 303);
}

export async function GET(req) {
  const productId = req.nextUrl.searchParams.get('product_id');
  const rows = (await q('SELECT * FROM reviews WHERE product_id = $1 ORDER BY id', [productId])).rows;
  return Response.json({ count: rows.length, reviews: rows });
}
