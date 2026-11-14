'use client';
import { useState } from 'react';

export default function Login() {
  const [email, setEmail] = useState('maya@vibeshop.test');
  const [password, setPassword] = useState('sunshine');
  const [out, setOut] = useState('');

  async function submit(e) {
    e.preventDefault();
    const r = await fetch('/api/login', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    const data = await r.json();
    setOut(r.status + ' ' + JSON.stringify(data));
    if (r.ok) setTimeout(() => (location.href = '/admin'), 400);
  }

  return (
    <main>
      <h1>Log in</h1>
      <form onSubmit={submit}>
        <p><input value={email} onChange={(e) => setEmail(e.target.value)} style={{ width: 280 }} /></p>
        <p><input value={password} onChange={(e) => setPassword(e.target.value)} /></p>
        <button>log in</button>
      </form>
      <p><a href="/signup">sign up</a> | <a href="/">home</a></p>
      <p>
        forgot? <a href="/api/forgot?email=maya@vibeshop.test">/api/forgot</a>
      </p>
      <pre>{out}</pre>
    </main>
  );
}
