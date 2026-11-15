import Link from 'next/link';
import { q } from '../../lib/db';
import { sortColumn } from '../../lib/searchSort';

export const dynamic = 'force-dynamic';

// the same naive query as the API route, written a second time, which is exactly what a dev does. the
// fix therefore has two call sites, and the exploit can hit either.
export default async function Search({ searchParams }) {
  const sp = await searchParams;
  const term = sp.q || '';
  const sort = sortColumn(sp.sort || 'id');
  const sql = `SELECT id, name, price_cents, image FROM products WHERE name ILIKE $1 ORDER BY ${sort} LIMIT 20`;

  let rows = [];
  let err = null;
  try {
    rows = (await q(sql, ['%' + term + '%'])).rows;
  } catch (e) {
    err = e.message;
  }

  return (
    <main>
      <h1>Search</h1>
      <form action="/search">
        <input name="q" defaultValue={term} placeholder="product name" />
        <select name="sort" defaultValue={sort}>
          <option value="id">id</option>
          <option value="name">name</option>
          <option value="price_cents">price_cents</option>
          <option value="price">price</option>
        </select>
        <button>search</button>
      </form>
      <p>results for: <b>{term}</b> (sorted by {sort})</p>
      <p className="sql"><code>{sql}</code></p>
      {err ? <p>error: {err}</p> : null}
      <ul>
        {rows.map((r) => (
          <li key={r.id}>{r.name} - {r.price_cents}</li>
        ))}
      </ul>
      <p><Link href="/">home</Link></p>
    </main>
  );
}
