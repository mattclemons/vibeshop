// Allowlist, scheme check and a timeout. An off-allowlist host is refused with a 400 that names it.
const ALLOW = new Set(['169.254.169.254', 'minio']);

export async function GET(req) {
  const url = req.nextUrl.searchParams.get('url');
  if (!url) return Response.json({ error: 'pass ?url=' }, { status: 400 });

  let u;
  try { u = new URL(url); } catch { return Response.json({ error: 'not a url' }, { status: 400 }); }
  if (!/^https?:$/.test(u.protocol)) {
    return Response.json({ error: 'scheme not allowed: ' + u.protocol }, { status: 400 });
  }
  if (!ALLOW.has(u.hostname)) {
    return Response.json({ error: 'host not on the import allowlist (' + [...ALLOW].join(', ') + ')' }, { status: 400 });
  }

  const started = Date.now();
  const r = await fetch(url, { redirect: 'follow', signal: AbortSignal.timeout(5000) });
  const body = await r.text();
  return Response.json({
    url, status: r.status, content_type: r.headers.get('content-type'),
    seen_from: r.headers.get('x-seen-from'), ms: Date.now() - started,
    len: body.length, body: body.slice(0, 4000),
  });
}
