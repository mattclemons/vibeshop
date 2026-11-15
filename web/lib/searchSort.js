// The sort column cannot be a bind parameter, so it is allowlisted. Anything else falls back to id.
const COLUMNS = new Set(['id', 'name', 'price_cents']);

export function sortColumn(requested) {
  return COLUMNS.has(requested) ? requested : 'id';
}
