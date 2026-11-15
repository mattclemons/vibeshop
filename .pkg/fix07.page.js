import Link from 'next/link';
import { q } from '../lib/db';

export const dynamic = 'force-dynamic';

export default async function Home() {
  const products = (await q('SELECT id, name, price_cents FROM products ORDER BY id LIMIT 8')).rows;

  return (
    <main>
      <h1>VibeShop</h1>
      <p>
        <Link href="/login">log in</Link> | <Link href="/signup">sign up</Link> |{' '}
        <Link href="/admin">admin</Link> | <Link href="/out?to=https://example.test/">out</Link> | <Link href="/orders">my orders</Link> |{' '}
        <Link href="/cart">cart</Link>
      </p>

      {/* module 17: a search box, because a shop needs one and a naive dev writes /api/search */}
      <form action="/search">
        <input name="q" placeholder="search products" />
        <button>search</button>
      </form>

      <div className="grid">
        {products.map((p) => (
          <div className="card" key={p.id}>
            <Link href={'/product/' + p.id}>{p.name}</Link>
            <div>{(p.price_cents / 100).toFixed(2)}</div>
          </div>
        ))}
      </div>

      <footer>
        <div>
          questions? <Link href="/out?to=http://legacy.vibeshop.test:8081/">legacy.vibeshop.test</Link> |{' '}
          <a href="/api/import?url=http://169.254.169.254/latest/meta-data/">import metadata</a>
        </div>
        <div>reset links are mailed by <Link href="/login">/api/forgot</Link></div>
      </footer>

      {/* module 7: third party script, no integrity, no version pin */}
      <script src="http://attacker.test:8081/tracker.js" integrity="sha384-VQg7684aJ4dUDxzsnMUGTykzMlV+f43vhyvwIL3QcsqmY3BmRdFV25WEuVS01J5S" crossOrigin="anonymous"></script>
    </main>
  );
}
