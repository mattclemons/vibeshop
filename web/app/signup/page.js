'use client';
import { useState } from 'react';

export default function Signup() {
  const [email, setEmail] = useState('new@vibeshop.test');
  const [password, setPassword] = useState('vibeshop');
  const [out, setOut] = useState('');

  async function submit(e) {
    e.preventDefault();
    const r = await fetch('/api/signup', {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    setOut(r.status + ' ' + JSON.stringify(await r.json()));
  }

  return (
    <main>
      <h1>Sign up</h1>
      <form onSubmit={submit}>
        <p><input value={email} onChange={(e) => setEmail(e.target.value)} style={{ width: 280 }} /></p>
        <p><input value={password} onChange={(e) => setPassword(e.target.value)} /></p>
        <button>create account</button>
      </form>
      <p>
        or continue with a provider:{' '}
        <a href={'/api/oauth/provider?email=' + encodeURIComponent(email)}>stub oauth</a>
      </p>
      <p><a href="/login">log in</a> | <a href="/">home</a></p>
      <pre>{out}</pre>
    </main>
  );
}
