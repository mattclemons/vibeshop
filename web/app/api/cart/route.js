import { cartId, cartState, addLine } from '../../../lib/cart';

async function readQty(req, sp) {
  let qty = sp.get('qty');
  if (qty == null && (req.headers.get('content-type') || '').includes('form')) {
    const f = await req.formData();
    qty = f.get('qty');
  }
  return qty == null ? '1' : String(qty);
}

export async function GET() {
  const id = await cartId();
  return Response.json(await cartState(id));
}

export async function POST(req) {
  const id = await cartId();
  const sp = req.nextUrl.searchParams;
  const productId = sp.get('product_id');
  if (!productId) return Response.json({ error: 'product_id required' }, { status: 400 });

  try {
    const state = await addLine(id, productId, await readQty(req, sp));
    return Response.json(state);
  } catch (e) {
    if (e && e.status === 400) {
      return Response.json({ error: e.message, value: String(e.value) }, { status: 400 });
    }
    throw e;
  }
}
