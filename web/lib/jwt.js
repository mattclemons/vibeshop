// hand-rolled HS256. no library, no Buffer: same code runs in the node runtime and in middleware.
const enc = new TextEncoder();
const dec = new TextDecoder();

function bytesToB64url(bytes) {
  let bin = '';
  for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]);
  return btoa(bin).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

function b64urlToBytes(str) {
  const pad = str.length % 4 === 0 ? '' : '='.repeat(4 - (str.length % 4));
  const bin = atob(str.replace(/-/g, '+').replace(/_/g, '/') + pad);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

const b64urlJson = (obj) => bytesToB64url(enc.encode(JSON.stringify(obj)));

function secret() {
  return process.env.JWT_SECRET || 'sunshine';
}

function hmacKey() {
  return crypto.subtle.importKey(
    'raw',
    enc.encode(secret()),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign', 'verify']
  );
}

export async function signToken(payload) {
  const data = b64urlJson({ alg: 'HS256', typ: 'JWT' }) + '.' + b64urlJson(payload);
  const sig = await crypto.subtle.sign('HMAC', await hmacKey(), enc.encode(data));
  return data + '.' + bytesToB64url(new Uint8Array(sig));
}

export async function verifyToken(token) {
  if (!token || token.split('.').length !== 3) return null;
  const [header, body, sig] = token.split('.');
  const ok = await crypto.subtle.verify(
    'HMAC',
    await hmacKey(),
    b64urlToBytes(sig),
    enc.encode(header + '.' + body)
  );
  if (!ok) return null;
  try {
    return JSON.parse(dec.decode(b64urlToBytes(body)));
  } catch {
    return null;
  }
}
