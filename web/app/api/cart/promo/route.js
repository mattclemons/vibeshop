import { cartId, applyPromo } from '../../../../lib/cart';

export async function POST(req) {
  const id = await cartId();
  const sp = req.nextUrl.searchParams;
  let code = sp.get('code');
  if (code == null && (req.headers.get('content-type') || '').includes('form')) {
    const f = await req.formData();
    code = f.get('code');
  }
  const state = await applyPromo(id, String(code || ''));
  return Response.json(state);
}
