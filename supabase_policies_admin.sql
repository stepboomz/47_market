-- =========================================================
-- RLS Policies: public read-only, authenticated full CRUD
-- (Idempotent: safe to re-run)
-- =========================================================

-- 1) Ensure RLS is enabled (harmless to run repeatedly)
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_sizes ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;

-- 2) Public read policies (if you already created elsewhere, you can skip)
DROP POLICY IF EXISTS "public read categories" ON categories;
CREATE POLICY "public read categories" ON categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "public read products" ON products;
CREATE POLICY "public read products" ON products FOR SELECT USING (true);

DROP POLICY IF EXISTS "public read product_variants" ON product_variants;
CREATE POLICY "public read product_variants" ON product_variants FOR SELECT USING (true);

DROP POLICY IF EXISTS "public read product_sizes" ON product_sizes;
CREATE POLICY "public read product_sizes" ON product_sizes FOR SELECT USING (true);

DROP POLICY IF EXISTS "public read orders" ON orders;
CREATE POLICY "public read orders" ON orders FOR SELECT USING (true);

DROP POLICY IF EXISTS "public read order_items" ON order_items;
CREATE POLICY "public read order_items" ON order_items FOR SELECT USING (true);

-- 3) Authenticated write policies (allow INSERT/UPDATE/DELETE for authenticated)
DROP POLICY IF EXISTS "auth write categories" ON categories;
CREATE POLICY "auth write categories" ON categories
  FOR ALL TO authenticated
  USING (true)     -- allow when reading for UPDATE/DELETE
  WITH CHECK (true); -- allow values being written

DROP POLICY IF EXISTS "auth write products" ON products;
CREATE POLICY "auth write products" ON products
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "auth write product_variants" ON product_variants;
CREATE POLICY "auth write product_variants" ON product_variants
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "auth write product_sizes" ON product_sizes;
CREATE POLICY "auth write product_sizes" ON product_sizes
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "auth write orders" ON orders;
CREATE POLICY "auth write orders" ON orders
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "auth write order_items" ON order_items;
CREATE POLICY "auth write order_items" ON order_items
  FOR ALL TO authenticated
  USING (true)
  WITH CHECK (true);
