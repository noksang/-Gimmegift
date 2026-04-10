-- ══════════════════════════════════════════════════════════════════
--  SUPABASE SQL SETUP — test1 Shop v34
--  URL: https://owhbmacdsfftyssgxmbt.supabase.co
--  วิธีใช้: SQL Editor → New query → วางทั้งหมด → RUN
--
--  ⚠️ ขั้นตอนสำคัญที่ต้องทำใน Supabase Dashboard ก่อน:
--
--  🔑 แก้ปัญหาสมัครสมาชิกไม่ได้ / อีเมลยืนยันไม่มา:
--  1. ไปที่ Supabase Dashboard: https://supabase.com/dashboard
--  2. เลือก Project ของคุณ
--  3. ไปที่เมนู Authentication (ซ้ายมือ)
--  4. คลิก "Providers" แล้วคลิก "Email"
--  5. ปิด "Confirm email" (toggle ให้เป็นสีเทา/OFF)
--  6. กด Save  ← สำคัญมาก!
--
--  หลังปิด Confirm email → สมัครสมาชิกแล้ว Login ได้ทันทีเลยค่ะ
--
--  📦 Storage สำหรับรูปภาพ:
--  - Storage → New Bucket → ชื่อ "product-images" → เปิด Public ✅
-- ══════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS products (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  price numeric NOT NULL DEFAULT 0,
  old_price numeric,
  category text DEFAULT 'new',
  description text,
  image text,
  images jsonb,
  colors jsonb,
  properties jsonb,
  specs jsonb,
  unit text DEFAULT 'ชิ้น',
  stock integer DEFAULT 0,
  sold integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- เพิ่ม column ใหม่ถ้ามี products table อยู่แล้ว
ALTER TABLE products ADD COLUMN IF NOT EXISTS images jsonb;
ALTER TABLE products ADD COLUMN IF NOT EXISTS colors jsonb;
ALTER TABLE products ADD COLUMN IF NOT EXISTS properties jsonb;
ALTER TABLE products ADD COLUMN IF NOT EXISTS specs jsonb;

CREATE TABLE IF NOT EXISTS ideas (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  title text NOT NULL,
  content text,
  description text,
  image text,
  category text DEFAULT 'tips',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS orders (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid,
  items jsonb,
  total numeric DEFAULT 0,
  status text DEFAULT 'pending',
  customer_email text,
  receipt_note text,
  created_at timestamptz DEFAULT now()
);

-- ══ ⚠️ รัน SQL เหล่านี้ใน Supabase SQL Editor ทุกครั้งที่ขึ้น error "column not found" ══
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_email text;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_name text;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_phone text;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_name text;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS shipping_address text;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS confirmed_at timestamptz;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS receipt_note text;

-- เพิ่ม column ใหม่ใน shop_settings (สำหรับ DB เดิม)
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS business_hours text;
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS banner_slides jsonb;
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS ticker_text text;

CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY,
  name text,
  email text,
  phone text,
  address text,
  role text DEFAULT 'user',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz
);

CREATE TABLE IF NOT EXISTS contact_messages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text,
  email text,
  phone text,
  message text,
  is_read boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS shop_settings (
  id integer PRIMARY KEY DEFAULT 1,
  shop_name text DEFAULT 'test1 Shop',
  description text,
  phone text,
  email text,
  address text,
  logo text,
  facebook text,
  line text,
  instagram text,
  tiktok text,
  promptpay text DEFAULT '0812345678',
  shipping_fee numeric DEFAULT 50,
  free_shipping_threshold numeric DEFAULT 500,
  updated_at timestamptz DEFAULT now()
);
INSERT INTO shop_settings(id,shop_name) VALUES(1,'test1 Shop') ON CONFLICT(id) DO NOTHING;

CREATE TABLE IF NOT EXISTS admin_accounts (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  username text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  display_name text,
  role text DEFAULT 'admin',
  is_active boolean DEFAULT true,
  last_login timestamptz,
  created_at timestamptz DEFAULT now()
);

-- RLS: เปิดแบบ public ทั้งหมด (dev mode)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE ideas ENABLE ROW LEVEL SECURITY;
ALTER TABLE ideas ADD COLUMN IF NOT EXISTS images jsonb;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS qr_image text;
-- VAT/WHT defaults are stored in localStorage (no DB column needed)
-- ⚠️ รัน 2 บรรทัดนี้ใน Supabase SQL Editor ถ้ายังไม่มี column address/updated_at
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS address text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS updated_at timestamptz;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE shop_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_accounts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "products_all" ON products;
CREATE POLICY "products_all" ON products FOR ALL USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "ideas_all" ON ideas;
CREATE POLICY "ideas_all" ON ideas FOR ALL USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "orders_all" ON orders;
DROP POLICY IF EXISTS "orders_select" ON orders;
DROP POLICY IF EXISTS "orders_insert" ON orders;
DROP POLICY IF EXISTS "orders_update" ON orders;
-- อนุญาตทุกคน (รวม anon) อ่าน/เขียน orders ได้ (dev mode)
CREATE POLICY "orders_all" ON orders FOR ALL TO anon, authenticated USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "profiles_all" ON profiles;
CREATE POLICY "profiles_all" ON profiles FOR ALL USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "contact_all" ON contact_messages;
CREATE POLICY "contact_all" ON contact_messages FOR ALL USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "settings_all" ON shop_settings;
CREATE POLICY "settings_all" ON shop_settings FOR ALL USING(true) WITH CHECK(true);
DROP POLICY IF EXISTS "admin_all" ON admin_accounts;
CREATE POLICY "admin_all" ON admin_accounts FOR ALL USING(true) WITH CHECK(true);

-- ════════════════════════════════════════
-- ระบบใบเสนอราคา / Quotation System
-- ════════════════════════════════════════
CREATE TABLE IF NOT EXISTS quotations (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  doc_no text,
  doc_type text DEFAULT 'quotation',
  source text DEFAULT 'admin',
  status text DEFAULT 'draft',
  customer_id uuid,
  customer_name text,
  customer_email text,
  customer_phone text,
  customer_taxid text,
  customer_address text,
  shipping_address text,
  tax_address text,
  issue_date date DEFAULT CURRENT_DATE,
  expire_days integer DEFAULT 30,
  expire_date date,
  items jsonb DEFAULT '[]',
  subtotal numeric DEFAULT 0,
  discount_amount numeric DEFAULT 0,
  shipping_fee numeric DEFAULT 0,
  vat_pct numeric DEFAULT 7,
  vat_amount numeric DEFAULT 0,
  wht_pct numeric DEFAULT 0,
  wht_amount numeric DEFAULT 0,
  total numeric DEFAULT 0,
  remark text,
  approved_by text,
  sent_to_email text,
  order_id uuid,
  created_by text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
ALTER TABLE quotations ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "quotations_all" ON quotations;
CREATE POLICY "quotations_all" ON quotations FOR ALL USING(true) WITH CHECK(true);

-- ════════════════════════════════════════
-- ระบบรีวิวสินค้า / Product Reviews
-- ════════════════════════════════════════
CREATE TABLE IF NOT EXISTS product_reviews (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id text NOT NULL,
  user_id uuid,
  user_name text,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE product_reviews ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "reviews_all" ON product_reviews;
CREATE POLICY "reviews_all" ON product_reviews FOR ALL USING(true) WITH CHECK(true);

-- Admin ทดสอบ
INSERT INTO admin_accounts(username,password_hash,display_name,role,is_active) VALUES
  ('admin','admin123','ผู้ดูแลระบบ','superadmin',true),
  ('manager','1234','ผู้จัดการร้าน','admin',true),
  ('superadmin','super999','Super Admin','superadmin',true)
ON CONFLICT(username) DO NOTHING;

-- สินค้าตัวอย่าง
INSERT INTO products(name,price,old_price,category,description,image,stock,sold,is_active) VALUES
  ('กระบอกน้ำ Eco Pro 500ml',299,399,'new','กระบอกน้ำสเตนเลส 304 เกรดอาหาร รักษาอุณหภูมิ 24 ชั่วโมง ปราศจาก BPA','https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=600&h=600&fit=crop',50,120,true),
  ('ถุงผ้า Canvas Tote Bag',149,199,'trend','ถุงผ้าแคนวาสคุณภาพสูง ทนทาน ล้างได้ รองรับน้ำหนักได้ถึง 10 กก.','https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&h=600&fit=crop',100,280,true),
  ('หลอดสเตนเลส Set 4 ชิ้น',189,null,'hot','ชุดหลอดสเตนเลส 4 ชิ้น พร้อมแปรงล้าง ใช้ซ้ำได้นาน','https://images.unsplash.com/photo-1559181567-c3190150d573?w=600&h=600&fit=crop',80,450,true),
  ('แก้วกาแฟเซรามิก มินิมอล',250,320,'best','แก้วกาแฟเซรามิกแฮนด์เมด ดีไซน์มินิมอล ความจุ 350ml','https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600&h=600&fit=crop',3,310,true),
  ('กล่องอาหาร Bento Box 4 ช่อง',350,450,'new','กล่องอาหาร 4 ช่อง สแตนเลส 304 ปลอดสาร BPA ฝาแน่นไม่รั่ว','https://images.unsplash.com/photo-1585032226651-759b368d7246?w=600&h=600&fit=crop',40,95,true),
  ('ผ้าขนหนูไม้ไผ่ Bamboo',199,null,'trend','ผ้าขนหนูจากใยไม้ไผ่ 100% นุ่ม ดูดซับน้ำดี','https://images.unsplash.com/photo-1620627099027-b1eb4c7d7f87?w=600&h=600&fit=crop',75,175,true),
  ('แปรงสีฟัน Bamboo Pack 3',89,null,'new','แปรงสีฟันจากไม้ไผ่ 3 แท่ง ย่อยสลายได้ ไม่ทิ้งพลาสติก','https://images.unsplash.com/photo-1607613009820-a29f7bb81c04?w=600&h=600&fit=crop',200,340,true),
  ('ขวดน้ำ Tritan 750ml',180,220,'hot','ขวดน้ำ Tritan ใสคริสตัล BPA Free น้ำหนักเบา ฝาล็อคกัน spill','https://images.unsplash.com/photo-1566665797739-1674de7a421a?w=600&h=600&fit=crop',120,410,true),
  ('กระเป๋า Eco Travel Bag',890,1200,'best','กระเป๋าเดินทางจากวัสดุรีไซเคิล PET ทนทาน กันน้ำ รับประกัน 2 ปี','https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&h=600&fit=crop',30,85,true),
  ('กาต้มน้ำ Kettle Eco 1L',650,850,'trend','กาต้มน้ำไฟฟ้าสแตนเลส 1 ลิตร 1500W ตัดไฟอัตโนมัติ','https://images.unsplash.com/photo-1544568100-847a948585b9?w=600&h=600&fit=crop',25,62,true)
ON CONFLICT DO NOTHING;

-- บทความตัวอย่าง
INSERT INTO ideas(title,content,image,category) VALUES
  ('5 วิธีลดขยะพลาสติกในบ้าน','ปัญหาขยะพลาสติกเป็นวิกฤตระดับโลก แต่เราช่วยได้ตั้งแต่วันนี้

1. พกถุงผ้าแทนถุงพลาสติก — ถุงผ้าหนึ่งใบทดแทนถุงพลาสติกได้นับพันใบ
2. ใช้กระบอกน้ำสเตนเลส — ประหยัดเงิน รักษาอุณหภูมิ 24 ชม.
3. หลีกเลี่ยงบรรจุภัณฑ์พลาสติก — เลือกกระดาษ แก้ว หรือโลหะ
4. ใช้หลอดสเตนเลส — เล็กเกินรีไซเคิล พกเองดีกว่า
5. ทำ Compost จากเศษอาหาร — ลดขยะ ได้ปุ๋ยฟรี

เริ่มจากนิสัยเล็กๆ วันนี้ เพื่อโลกที่ดีกว่าพรุ่งนี้!','https://images.unsplash.com/photo-1542601906897-d3b52ca00e0f?w=800&h=500&fit=crop','tips'),

  ('DIY: ถุงผ้าจากเสื้อยืดเก่า 10 นาที ไม่ต้องเย็บ!','อุปกรณ์: เสื้อยืด + กรรไกร เท่านั้น!

ขั้นตอน:
1. ตัดคอเสื้อออกเป็นรูปตัว U
2. ตัดแขนทั้งสองข้างออก
3. ตัดชายเสื้อด้านล่างเป็นริ้วๆ กว้าง 2 ซม. ยาว 10 ซม.
4. ผูกริ้วหน้า-หลังเป็นคู่จนครบ — ก้นถุงปิดสนิท
5. ตกแต่งด้วยสีผ้าตามใจชอบ

ง่ายมาก ได้ถุงช้อปปิ้งสุดเก๋ ลดขยะผ้าและพลาสติกพร้อมกัน!','https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=500&fit=crop','diy'),

  ('รีวิว: กระบอกน้ำสเตนเลส 30 วัน ดีแค่ไหน?','ใช้กระบอกน้ำ Eco Pro ครบ 30 วัน มาเล่าให้ฟัง

ข้อดี:
★ รักษาความเย็น 24 ชม. จริง ทดสอบแล้ว
★ ไม่รั่วซึม วางนอนทิ้ง 1 ชม. ไม่มีน้ำออก
★ ประหยัดเงิน เดือนละ 300-400 บาท
★ ล้างง่าย ปากกว้าง ใช้แปรงได้

ข้อเสีย:
- ต้องล้างทุกวัน แต่ก็ง่ายมาก

คะแนน: 9/10 แนะนำมากค่ะ!','https://images.unsplash.com/photo-1602143407151-7111542de6e8?w=800&h=500&fit=crop','review'),

  ('ไทยแบนพลาสติกครั้งเดียว ปี 2570','กรมควบคุมมลพิษประกาศยกเลิกพลาสติกใช้ครั้งเดียวทิ้งภายใน 2570

สิ่งที่จะถูกแบน:
- ถุงพลาสติกหูหิ้ว
- หลอดพลาสติก (ยกเว้นทางการแพทย์)
- กล่องโฟมบรรจุอาหาร
- แก้วพลาสติกแบบใช้ครั้งเดียว

เตรียมพร้อมได้เลยโดยเปลี่ยนมาใช้สินค้า Eco-Friendly ตั้งแต่วันนี้!','https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=800&h=500&fit=crop','news')
ON CONFLICT DO NOTHING;

/*
  ══════════════════════════════════════════
   CHECKLIST หลังรัน SQL
  ══════════════════════════════════════════
  ✅ รัน SQL สำเร็จ

  🔑 แก้สมัครสมาชิกไม่ได้ (สำคัญมาก!):
  ✅ Authentication → Providers → Email → ปิด "Confirm email" → Save
       (ถ้าไม่ปิด จะสมัครได้แต่ login ไม่ได้ / อีเมลยืนยันไม่มา)

  ✅ Storage → สร้าง Bucket "product-images" (เปิด Public)
  ✅ Deploy ไฟล์ทั้งหมดขึ้น Netlify / เว็บโฮสต์

  ADMIN LOGIN (ที่หน้า admin.html):
  Username: admin     | Password: admin123
  Username: manager   | Password: 1234
  Username: superadmin| Password: super999
*/

-- ════════════════════════════════════════
-- v33 — เพิ่ม column ใหม่ (รัน SQL นี้ใน Supabase ถ้าอัปเกรดจาก v32)
-- ════════════════════════════════════════

-- ใบเสนอราคา: เพิ่ม approved_at และ customer_company
ALTER TABLE quotations ADD COLUMN IF NOT EXISTS approved_at timestamptz;
ALTER TABLE quotations ADD COLUMN IF NOT EXISTS customer_company text;

-- ข้อมูลบริษัทและลายเซ็นใน shop_settings
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS company_name  text;
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS company_addr  text;
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS company_phone text;
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS company_fax   text;
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS company_taxid text;
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS sig1_url      text;
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS sig2_url      text;
ALTER TABLE shop_settings ADD COLUMN IF NOT EXISTS sig3_url      text;

-- ════════════════════════════════════════
-- v35 — ระบบถังขยะ / Soft Delete
-- รัน SQL นี้ใน Supabase SQL Editor
-- ════════════════════════════════════════

CREATE TABLE IF NOT EXISTS deleted_items (
  id          uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  original_table text NOT NULL,
  original_id    text NOT NULL,
  display_name   text,
  data_snapshot  jsonb,
  deleted_by     text,
  deleted_at     timestamptz DEFAULT now(),
  expires_at     timestamptz DEFAULT (now() + interval '30 days')
);

ALTER TABLE deleted_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "deleted_all" ON deleted_items;
CREATE POLICY "deleted_all" ON deleted_items FOR ALL USING(true) WITH CHECK(true);

-- Auto-purge: ลบอัตโนมัติเมื่อครบ 30 วัน (ถ้า Supabase มี pg_cron)
-- SELECT cron.schedule('purge-trash', '0 2 * * *', $$DELETE FROM deleted_items WHERE expires_at < now()$$);

-- v38 — เพิ่ม column discount_pct ใน quotations
ALTER TABLE quotations ADD COLUMN IF NOT EXISTS discount_pct numeric DEFAULT 0;
