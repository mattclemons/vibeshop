import { q } from '../../../lib/db';

// module 17: the search box an inexperienced dev (or an AI) writes.
//
//   - the value goes into the query with a template literal, so a quote breaks out of the string
//   - the ORDER BY column is concatenated too, because a bind parameter cannot cover an identifier
//   - the built SQL is echoed back, which is what makes the injection visible in the response
//
// exits nothing on its own; the exploit and the test live next door.
export async function GET(req) {
  const p = req.nextUrl.searchParams;
  const term = p.get('q') || '';
  const sort = p.get('sort') || 'id';

  const sql = `SELECT id, name, price_cents, image FROM products
               WHERE name ILIKE '%${term}%'
               ORDER BY ${sort} LIMIT 20`;

  try {
    const rows = (await q(sql)).rows;
    return Response.json({
      q: term,
      sort,
      count: rows.length,
      sql: sql.replace(/\s+/g, ' ').trim(),
      rows,
    });
  } catch (e) {
    return Response.json({ error: e.message, sql: sql.replace(/\s+/g, ' ').trim() }, { status: 500 });
  }
}
