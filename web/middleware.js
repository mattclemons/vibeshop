import { NextResponse } from 'next/server';
import { verifyToken } from './lib/jwt';

// The one and only gate in front of /admin. The admin route handler re-checks nothing.
export async function middleware(req) {
  const token = req.cookies.get('vs_session')?.value;
  const session = token ? await verifyToken(token) : null;

  if (!session) {
    return NextResponse.redirect(new URL('/login', req.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: ['/admin/:path*'],
};
