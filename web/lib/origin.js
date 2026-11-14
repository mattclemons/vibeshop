export function origin(req) {
  const host = req.headers.get('host');
  const proto = req.headers.get('x-forwarded-proto') || 'http';
  return host ? proto + '://' + host : req.url;
}

