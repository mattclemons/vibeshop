import Link from 'next/link';
import { cookies } from 'next/headers';
import { q } from '../../lib/db';
import { getSession } from '../../lib/auth';

export const dynamic = 'force-dynamic';

// the page version of the same thing: "my orders", with no filter, and the owner's email shown next to
// each row so the mismatch is visible without opening a terminal.
export default async function Orders() {
  const session = await getSession({ cookies: await cookies() });

  const rows = (
    await q(`SELECT o.id, o.user_id, o.amount, o.status, o.created_at, u.email AS owner
               FROM orders o LEFT JOIN users u ON u.id = o.user_id
              ORDER BY o.id`)
  ).rows;

  return (
    <main>
      <h1>My orders</h1>
      <p>you are: {session ? `${session.email} (id ${session.sub})` : 'not logged in'}</p>
      <table>
        <tbody>
          {rows.map((o) => (
            <tr key={o.id}>
              <td>{o.id}</td>
              <td>{o.owner || 'nobody'}</td>
              <td>{o.amount}</td>
              <td>{o.status}</td>
            </tr>
          ))}
        </tbody>
      </table>
      <p><Link href="/">home</Link></p>
    </main>
  );
}
