import { NextResponse } from 'next/server';

// no allowlist, no scheme check, no relative-path handling
export async function GET(req) {
  const to = req.nextUrl.searchParams.get('to');
  if (!to) return NextResponse.json({ error: 'pass ?to=' }, { status: 400 });
  return NextResponse.redirect(to);
}
