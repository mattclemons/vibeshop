'use client';
import { useState } from 'react';

export default function Reset() {
  const [password, setPassword] = useState('vibeshop2');
  const [out, setOut] = useState('');

  async function submit(e) {
    e.preventDefault();
    const token = new URLSearchParams(location.search).get('token') || '';
    const r = await fetch('/api/reset', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ token, password }),
    });
    setOut(r.status + ' ' + JSON.stringify(await r.json()));
  }

  return (
    <main>
      <h1>Set a new password</h1>
      <p>token from the link in the mail is reused automatically.</p>
      <form onSubmit={submit}>
        <p><input value={password} onChange={(e) => setPassword(e.target.value)} /></p>
        <button>reset</button>
      </form>
      <pre>{out}</pre>
    </main>
  );
}
