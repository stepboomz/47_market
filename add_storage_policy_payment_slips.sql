-- Create storage policy for payment-slips bucket
-- This allows public to upload and read slip images

-- First, make sure the bucket exists (you need to create it manually in Supabase Dashboard > Storage)
-- Then run this SQL to create the policies

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Allow public to upload payment slips" ON storage.objects;
DROP POLICY IF EXISTS "Allow public to read payment slips" ON storage.objects;

-- Policy for INSERT (upload)
CREATE POLICY "Allow public to upload payment slips"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (
  bucket_id = 'payment-slips'
);

-- Policy for SELECT (read)
CREATE POLICY "Allow public to read payment slips"
ON storage.objects
FOR SELECT
TO public
USING (
  bucket_id = 'payment-slips'
);

-- Alternative: If you want authenticated users only, use this instead:
-- DROP POLICY IF EXISTS "Allow authenticated to upload payment slips" ON storage.objects;
-- DROP POLICY IF EXISTS "Allow authenticated to read payment slips" ON storage.objects;
-- 
-- CREATE POLICY "Allow authenticated to upload payment slips"
-- ON storage.objects
-- FOR INSERT
-- TO authenticated
-- WITH CHECK (
--   bucket_id = 'payment-slips'
-- );
-- 
-- CREATE POLICY "Allow authenticated to read payment slips"
-- ON storage.objects
-- FOR SELECT
-- TO authenticated
-- USING (
--   bucket_id = 'payment-slips'
-- );

