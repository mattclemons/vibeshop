// In-memory sliding window, per account and per address. Enough for the lab; a real deployment
// would back this with a shared store so it survives more than one process.
const WINDOW_MS = 60_000;
const PER_ACCOUNT = 10;
const PER_ADDRESS = 100;

const byAccount = new Map();
const byAddress = new Map();

function hit(map, key, limit) {
  const now = Date.now();
  const e = map.get(key);
  if (!e || now - e.start > WINDOW_MS) {
    map.set(key, { start: now, n: 1 });
    return { blocked: false, retry: 0 };
  }
  e.n += 1;
  if (e.n > limit) return { blocked: true, retry: Math.ceil((WINDOW_MS - (now - e.start)) / 1000) };
  return { blocked: false, retry: 0 };
}

export function check(email, address) {
  const a = hit(byAccount, email || '?', PER_ACCOUNT);
  if (a.blocked) return a;
  return hit(byAddress, address || '?', PER_ADDRESS);
}

export function clear(email) {
  byAccount.delete(email || '?');
}
