// module 19: the escaper you write when you have read "escape your HTML" and stopped reading.
// it neutralises tags, which is the part everyone remembers, and leaves the quote alone, which is the part
// that matters the moment the value lands in a quoted attribute instead of element text. it also leaves
// & alone, so an existing entity in the data is at the mercy of whatever follows it.
export function esc(s) {
  return String(s == null ? '' : s)
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}
