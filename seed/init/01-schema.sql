-- VibeShop schema. naive on purpose.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
  id              serial PRIMARY KEY,
  email           text NOT NULL,
  password_hash   text,
  role            text NOT NULL DEFAULT 'customer',
  email_confirmed boolean NOT NULL DEFAULT false,
  reset_token     text,
  oauth_sub       text,
  oauth_provider  text,
  created_at      timestamptz NOT NULL DEFAULT '2026-01-01 09:00:00+00'
);

-- note: no unique index on email. two accounts can share an address.
CREATE TABLE products (
  id          serial PRIMARY KEY,
  name        text NOT NULL,
  description text NOT NULL DEFAULT '',
  price_cents integer NOT NULL,
  image       text NOT NULL DEFAULT 'placeholder.png'
);

CREATE TABLE orders (
  id         serial PRIMARY KEY,
  product_id integer NOT NULL,
  user_id    integer,
  -- no foreign key, and no unique anything: a naive schema gives the module something to compare
  amount     integer NOT NULL,
  status     text NOT NULL DEFAULT 'paid',
  created_at timestamptz NOT NULL DEFAULT '2026-01-02 10:00:00+00'
);

CREATE TABLE reviews (
  id         serial PRIMARY KEY,
  product_id integer NOT NULL,
  author     text NOT NULL,
  body       text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE carts (
  cart_id    text NOT NULL,
  product_id integer NOT NULL,
  qty        numeric NOT NULL DEFAULT 1,
  added_at   timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (cart_id, product_id)
);

CREATE TABLE cart_promos (
  cart_id  text PRIMARY KEY,
  code     text,
  discount numeric NOT NULL DEFAULT 0
);
