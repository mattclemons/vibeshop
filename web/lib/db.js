import { Pool } from 'pg';

export const pool = new Pool({ connectionString: process.env.DATABASE_URL });

export function q(text, params) {
  return pool.query(text, params);
}
