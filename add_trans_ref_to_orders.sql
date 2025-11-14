-- Add trans_ref column to orders table to prevent duplicate slip usage
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS trans_ref TEXT;

-- Create index for faster lookup
CREATE INDEX IF NOT EXISTS idx_orders_trans_ref ON orders(trans_ref);

-- Add comment
COMMENT ON COLUMN orders.trans_ref IS 'Transaction reference from payment slip verification to prevent duplicate usage';

