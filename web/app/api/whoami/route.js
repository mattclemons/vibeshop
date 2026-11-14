export const dynamic = 'force-dynamic';

// what the app actually sees. used by the smoke tests and by several modules.
export async function GET(req) {
  const h = Object.fromEntries(req.headers.entries());
  return Response.json({
    host: h.host,
    forwarded_host: h['x-forwarded-host'],
    forwarded_for: h['x-forwarded-for'],
    subrequest: h['x-middleware-subrequest'] || null,
    method: req.method,
    url: req.url,
  });
}
