import { cookies } from 'next/headers';
import { redirect, notFound } from 'next/navigation';
import { q } from '../../../lib/db';
import { verifyToken } from '../../../lib/jwt';

export const dynamic = 'force-dynamic';

export default async function Order({ params }) {
  const { id } = await params;
  const token = (await cookies()).get('vs_session')?.value;
  const session = token ? await verifyToken(token) : null;
  if (!session) redirect('/login');
  const order = (await q('SELECT * FROM orders WHERE id = $1 AND user_id = $2', [id, Number(session.sub)])).rows[0];
  if (!order) notFound();
  return (
    <main>
      <h1>Order {id}</h1>
      <pre>{JSON.stringify(order, null, 1)}</pre>
      <p><a href="/">home</a></p>
    </main>
  );
}
