-- Add UPDATE policy for promo_codes table
-- This allows the app to update used_count when a promo code is used

-- Drop policy if exists (to allow re-running)
DROP POLICY IF EXISTS "Allow update used_count on promo codes" ON promo_codes;

-- Create policy: Allow update of used_count (for incrementing usage counter)
CREATE POLICY "Allow update used_count on promo codes"
ON promo_codes FOR UPDATE
USING (true)
WITH CHECK (true);

