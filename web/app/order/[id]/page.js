import { q } from '../../../lib/db';

export const dynamic = 'force-dynamic';

export default async function Order({ params }) {
  const { id } = await params;
  const order = (await q('SELECT * FROM orders WHERE id = $1', [id])).rows[0];
  return (
    <main>
      <h1>Order {id}</h1>
      <pre>{JSON.stringify(order, null, 1)}</pre>
      <p><a href="/">home</a></p>
    </main>
  );
}
