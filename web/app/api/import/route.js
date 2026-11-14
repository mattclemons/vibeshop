// server-side fetch of any URL the user hands over. no allowlist, no pinning.
export async function GET(req) {
  const url = req.nextUrl.searchParams.get('url');
  if (!url) return Response.json({ error: 'pass ?url=' }, { status: 400 });

  const started = Date.now();
  const r = await fetch(url, { redirect: 'follow' });
  const body = await r.text();

  return Response.json({
    url,
    status: r.status,
    content_type: r.headers.get('content-type'),
    seen_from: r.headers.get('x-seen-from'),
    ms: Date.now() - started,
    len: body.length,
    body: body.slice(0, 4000),
  });
}
