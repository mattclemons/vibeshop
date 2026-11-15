import { NextResponse } from 'next/server';

// Allowlist the target. A host-relative path is honoured; an absolute url is honoured only if it
// points at the shop itself; anything else falls back to the shop root.
const SHOP = process.env.SITE_ORIGIN || 'http://vibeshop.test';

export async function GET(req) {
  const to = req.nextUrl.searchParams.get('to');
  if (!to) return NextResponse.json({ error: 'pass ?to=' }, { status: 400 });

  if (/^\/($|[^/])/.test(to)) {
    return NextResponse.redirect(new URL(to, SHOP));
  }
  try {
    const u = new URL(to);
    if (u.host === new URL(SHOP).host) return NextResponse.redirect(u.toString());
  } catch {
    // not a parseable absolute url
  }
  return NextResponse.redirect(new URL('/', SHOP));
}
