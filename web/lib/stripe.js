// No real Stripe account anywhere in this lab. These are junk keys shaped like the real thing.
// They get rotated once, in a later commit, and nobody notices the old one is still in git.
export const STRIPE_SECRET_KEY = 'sk_live_51JUNKoriginal000000000000000';
export const STRIPE_PUBLISHABLE_KEY = 'pk_live_51JUNKvibeshop0000000000000000';

// naive stub: the client sends the amount, so why ask Stripe anything
export async function charge({ amount, currency = 'gbp' }) {
  return { id: 'ch_junk_' + amount, amount, currency, status: 'succeeded' };
}
