-- fixed ids, fixed timestamps, deliberately weak passwords.
-- password_hash is sha256(plain), matching web/lib/auth.js

INSERT INTO users (id, email, password_hash, role, email_confirmed, created_at) VALUES
  (1, 'admin@vibeshop.test', encode(digest('admin123','sha256'),'hex'), 'admin',    true,  '2026-01-01 09:00:00+00'),
  (2, 'maya@vibeshop.test',  encode(digest('sunshine','sha256'),'hex'), 'customer', true,  '2026-01-01 09:05:00+00'),
  (3, 'sam@vibeshop.test',   encode(digest('password','sha256'),'hex'), 'customer', true,  '2026-01-01 09:10:00+00'),
  (4, 'leo@vibeshop.test',   encode(digest('qwerty','sha256'),'hex'),   'customer', true,  '2026-01-01 09:15:00+00'),
  (5, 'nina@vibeshop.test',  encode(digest('iloveyou','sha256'),'hex'), 'customer', true,  '2026-01-01 09:20:00+00'),
  (6, 'omar@vibeshop.test',  encode(digest('dragon','sha256'),'hex'),   'customer', true,  '2026-01-01 09:25:00+00'),
  (7, 'priya@vibeshop.test', encode(digest('letmein','sha256'),'hex'),  'customer', true,  '2026-01-01 09:30:00+00'),
  (8, 'quinn@vibeshop.test', encode(digest('vibeshop','sha256'),'hex'), 'customer', false, '2026-01-01 09:35:00+00');

SELECT setval('users_id_seq', 8);

INSERT INTO products (id, name, description, price_cents) VALUES
  (1,'Vibe Mug','ceramic, holds 350ml',1299),
  (2,'Vibe Mug XL','ceramic, holds 500ml',1599),
  (3,'Sticker Pack','six stickers',499),
  (4,'Tote Bag','canvas',1899),
  (5,'Socks (pair)','one size',899),
  (6,'Notebook','dot grid, 120 pages',1099),
  (7,'Pen','black ink',299),
  (8,'Hoodie','heavyweight',4999),
  (9,'T-Shirt','rings spun cotton',2499),
  (10,'Cap','adjustable',1999),
  (11,'Water Bottle','steel, 700ml',2799),
  (12,'Laptop Sleeve','13 inch',3299),
  (13,'Keyring','brass',699),
  (14,'Poster','A2',1499),
  (15,'Enamel Pin','hard enamel',799),
  (16,'Coaster Set','four pieces',1199),
  (17,'Tea Towel','linen',999),
  (18,'Apron','cotton',2299),
  (19,'Chef Knife','stainless',4599),
  (20,'Cutting Board','bamboo',3099),
  (21,'Desk Mat','large',3499),
  (22,'Cable Tidy','set of five',599),
  (23,'Phone Stand','aluminium',1699),
  (24,'Mouse Pad','cloth',899),
  (25,'USB Hub','four port',2599),
  (26,'Webcam Cover','three pack',399),
  (27,'Screen Wipes','fifty',299),
  (28,'Air Freshener','cedar',549),
  (29,'Candle','soy, 40 hours',1899),
  (30,'Plant Pot','terracotta',1349),
  (31,'Seed Kit','basil',749),
  (32,'Umbrella','compact',2399),
  (33,'Beanie','wool blend',1699),
  (34,'Scarf','long',2199),
  (35,'Gloves','touchscreen',1999),
  (36,'Belt','leather',2899),
  (37,'Wallet','bifold',3399),
  (38,'Sunglasses','polarised',2499),
  (39,'Watch Strap','silicone',1299),
  (40,'Gift Card','loadable',5000);

SELECT setval('products_id_seq', 40);

INSERT INTO orders (id, product_id, user_id, amount, status, created_at) VALUES
  (1, 8,  2, 4999, 'paid',     '2026-01-05 11:00:00+00'),
  (2, 3,  3, 499,  'paid',     '2026-01-05 11:30:00+00'),
  (3, 11, 1, 2799, 'shipped',  '2026-01-06 08:15:00+00'),
  (4, 19, 2, 4599, 'paid',     '2026-01-06 09:45:00+00');

SELECT setval('orders_id_seq', 4);

INSERT INTO reviews (id, product_id, author, body) VALUES
  (1, 1, 'dana',  'solid mug, keeps coffee hot'),
  (2, 1, 'sam',   'arrived chipped, <b>but</b> they replaced it'),
  (3, 2, 'priya', 'the XL is comically large. 10/10'),
  (4, 3, 'quinn', 'cheaper elsewhere, AT&T still charges tax twice');

SELECT setval('reviews_id_seq', 4);
