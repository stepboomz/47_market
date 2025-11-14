-- Add slip_image_url column to orders table to store payment slip image URL
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS slip_image_url TEXT;

-- Add comment
COMMENT ON COLUMN orders.slip_image_url IS 'URL of the payment slip image stored in Supabase Storage';

