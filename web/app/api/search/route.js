import { q } from '../../../lib/db';
import { sortColumn } from '../../../lib/searchSort';

// The value is bound; only the identifier is interpolated, and only from an allowlist.
export async function GET(req) {
  const p = req.nextUrl.searchParams;
  const term = p.get('q') || '';
  const sort = sortColumn(p.get('sort') || 'id');

  const sql = `SELECT id, name, price_cents, image FROM products
               WHERE name ILIKE $1
               ORDER BY ${sort} LIMIT 20`;

  try {
    const rows = (await q(sql, ['%' + term + '%'])).rows;
    return Response.json({ q: term, sort, count: rows.length, sql: sql.replace(/\s+/g, ' ').trim(), rows });
  } catch (e) {
    return Response.json({ error: e.message, sql: sql.replace(/\s+/g, ' ').trim() }, { status: 500 });
  }
}
