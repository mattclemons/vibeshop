import { cookies } from 'next/headers';
import { redirect } from 'next/navigation';
import { q } from '../../lib/db';
import { verifyToken } from '../../lib/jwt';

export const dynamic = 'force-dynamic';

// The admin page verifies the session itself. Middleware is now a cheap early exit, not the boundary,
// so the loop-guard header bypass reaches a page that still refuses it.
export default async function Admin() {
  const token = (await cookies()).get('vs_session')?.value;
  const session = token ? await verifyToken(token) : null;
  if (!session || session.role !== 'admin') redirect('/login');

  const users = (await q('SELECT count(*)::int AS n FROM users')).rows[0].n;
  const orders = (await q('SELECT count(*)::int AS n, coalesce(sum(amount),0)::int AS total FROM orders')).rows[0];
  const rows = (await q('SELECT id, email, role, email_confirmed FROM users ORDER BY id')).rows;

  return (
    <main>
      <h1>Admin</h1>
      <p>users: {users} | orders: {orders.n} | gross: {orders.total} cents</p>
      <table>
        <tbody>
          {rows.map((u) => (
            <tr key={u.id}>
              <td>{u.id}</td>
              <td>{u.email}</td>
              <td>{u.role}</td>
              <td>{String(u.email_confirmed)}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <p><a href="/">home</a></p>
    </main>
  );
}
